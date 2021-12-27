//
//  ARMDDC.swift
//  Transitions
//
//  Created by Sebastian Wild on 10/3/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Combine
import DDC
import Foundation

class ARMDDC {
    let displayID: CGDirectDisplayID
    private let service: IORegService
    private var readingCancellable: AnyCancellable?

    init?(for displayID: CGDirectDisplayID) {
        self.displayID = displayID
        guard let service = IORegUtils.service(for: displayID) else { return nil }
        guard service.service != nil else { return nil }
        self.service = service
    }

    private func read(command: DDC.Command, tries _: UInt8 = 3, minReplyDelay _: UInt32 = 10000) -> AnyPublisher<(current: UInt16, max: UInt16), DDCError> {
        guard let ioAVService = service.service else {
            return Fail(error: DDCError.serviceUnavailable).eraseToAnyPublisher()
        }
        let readSleepTime: TimeInterval = 0.01
        let attempts = 3

        let send: [UInt8] = [command.rawValue]
        var paddedSend = [UInt8(0x80 | (send.count + 1)), UInt8(send.count)] + send + [0]
        paddedSend[paddedSend.count - 1] = paddedSend.checksum(
            initial: send.count == 1 ? 0x6E : 0x6E ^ 0x51,
            range: ClosedRange<Int>(uncheckedBounds: (0, paddedSend.count - 2))
        )

        return writeI2COnQueue(with: ioAVService, inputBuffer: &paddedSend, inputBufferSize: UInt32(paddedSend.count))
            .receive(on: ARMDDC.queue) // Might be redundant
            .delay(for: .seconds(readSleepTime), scheduler: ARMDDC.queue)
            .flatMap { [unowned self] _ in readI2COnQueue(with: ioAVService) }
            .map { reply -> (current: UInt16, max: UInt16) in
                let max = UInt16(reply[6]) * 256 + UInt16(reply[7])
                let current = UInt16(reply[8]) * 256 + UInt16(reply[9])
                return (current, max)
            }
            .retry(attempts)
            .eraseToAnyPublisher()
    }

    private func write(command: DDC.Command, value: UInt16) -> AnyPublisher<Void, DDCError> {
        guard let ioAVService = service.service else {
            return Fail(error: DDCError.serviceUnavailable).eraseToAnyPublisher()
        }
        let writeSleepTime: TimeInterval = 0.01
        let attempts = 3

        let send: [UInt8] = [command.rawValue, UInt8(value >> 8), UInt8(value & 255)]

        var paddedSend = [UInt8(0x80 | (send.count + 1)), UInt8(send.count)] + send + [0]
        paddedSend[paddedSend.count - 1] = paddedSend.checksum(
            initial: send.count == 1 ? 0x6E : 0x6E ^ 0x51,
            range: ClosedRange<Int>(uncheckedBounds: (0, paddedSend.count - 2))
        )

        return writeI2COnQueue(with: ioAVService, inputBuffer: &paddedSend, inputBufferSize: UInt32(paddedSend.count))
            .receive(on: ARMDDC.queue) // Might be redundant
            // TODO: Delay is added even when write is successful! Should not be the case.
            .delay(for: .seconds(writeSleepTime), scheduler: ARMDDC.queue)
            .retry(attempts)
            .eraseToAnyPublisher()
    }

    private func readI2COnQueue(
        with service: IOAVService,
        chipAddress: UInt32 = 0x37,
        dataAddress: UInt32 = 0x51
    ) -> AnyPublisher<[UInt8], DDCError> {
        Deferred { () -> PassthroughSubject<[UInt8], DDCError> in
            // TODO: How to do this better?
            let subject = PassthroughSubject<[UInt8], DDCError>()
            var reply = [UInt8](repeating: 0, count: 11)

            ARMDDC.queue.async {
                let success = IOAVServiceReadI2C(service, chipAddress, dataAddress, &reply, UInt32(reply.count)) == 0
                if !success {
                    subject.send(completion: .failure(.readFailure))
                }

                if reply.checksum(initial: 0x50, range: ClosedRange(uncheckedBounds: (0, reply.count - 2))) != reply[reply.count - 1] {
                    subject.send(completion: .failure(.checksumValidationFailed))
                }

                subject.send(reply)
            }

            return subject
        }.eraseToAnyPublisher()
    }

    private func writeI2COnQueue(
        with service: IOAVService,
        chipAddress: UInt32 = 0x37,
        dataAddress: UInt32 = 0x51,
        inputBuffer: UnsafeMutableRawPointer,
        inputBufferSize: UInt32
    ) -> AnyPublisher<Void, DDCError> {
        Deferred { () -> PassthroughSubject<Void, DDCError> in
            // TODO: How to do this better?
            let subject = PassthroughSubject<Void, DDCError>()

            ARMDDC.queue.async {
                let success = IOAVServiceWriteI2C(service, chipAddress, dataAddress, inputBuffer, inputBufferSize) == 0
                success ? subject.send() : subject.send(completion: .failure(.writeFailure))
            }

            return subject
        }.eraseToAnyPublisher()
    }
}

extension ARMDDC: DDCControlling {
    func readBrightness() -> BrightnessReading {
        let waitGroup = DispatchGroup()
        waitGroup.enter()
        // TODO: Refactor this to use async/await...or refactor DDCControlling protocol to use Publishers
        var reading = BrightnessReading.success(0.0)
        readingCancellable = read(command: .brightness)
            .sink(receiveCompletion: { [unowned self] completion in
                if case let .failure(error) = completion {
                    reading = .failure(.readError(
                        displayMetadata: displayID.metadata,
                        original: error
                    )
                    )
                }
            }, receiveValue: { [unowned self] current, max in
                guard max != 0 else {
                    reading = .failure(BrightnessReadError.readError(displayMetadata: displayID.metadata, original: nil))
                    waitGroup.leave()
                    return
                }

                reading = .success(Float(current) / Float(max))
                waitGroup.leave()
            })

        waitGroup.wait()
        return reading
    }

    func readDisplayName() -> String {
        service.productName
    }
}

extension ARMDDC {
    static let queue = DispatchQueue(label: "Transtitions DDC Queue", qos: .background)

    enum DDCError: Error {
        case checksumValidationFailed
        case serviceUnavailable
        case writeFailure
        case readFailure
    }
}

private extension Array where Element == UInt8 {
    func checksum(initial: UInt8, range: ClosedRange<Int>) -> UInt8 {
        var check = initial
        for index in range {
            check ^= self[index]
        }

        return check
    }
}
