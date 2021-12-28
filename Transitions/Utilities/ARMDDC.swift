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

actor ARMDDC {
    let displayID: CGDirectDisplayID
    private let service: IORegService
    private var readingCancellable: AnyCancellable?

    init?(for displayID: CGDirectDisplayID) {
        self.displayID = displayID
        guard let service = IORegUtils.service(for: displayID) else { return nil }
        guard service.service != nil else { return nil }
        self.service = service
    }

    private func read(command: DDC.Command, tries _: UInt8 = 3, minReplyDelay _: UInt32 = 10000) async throws -> (current: UInt16, max: UInt16) {
        guard let ioAVService = service.service else {
            throw DDCError.serviceUnavailable
        }
        let readSleepTime = UInt64(0.01 * 1000 * 1000 * 1000) // 0.01 seconds in nanoseconds
        let attempts = 3

        let send: [UInt8] = [command.rawValue]
        var paddedSend = [UInt8(0x80 | (send.count + 1)), UInt8(send.count)] + send + [0]
        paddedSend[paddedSend.count - 1] = paddedSend.checksum(
            initial: send.count == 1 ? 0x6E : 0x6E ^ 0x51,
            range: ClosedRange<Int>(uncheckedBounds: (0, paddedSend.count - 2))
        )

        var readError: DDCError?
        var attemptCount = 0
        repeat {
            do {
                attemptCount += 1

                try writeI2COnQueue(with: ioAVService, inputBuffer: &paddedSend, inputBufferSize: UInt32(paddedSend.count))
                try await Task.sleep(nanoseconds: readSleepTime)
                let reply = try readI2COnQueue(with: ioAVService)

                let max = UInt16(reply[6]) * 256 + UInt16(reply[7])
                let current = UInt16(reply[8]) * 256 + UInt16(reply[9])
                return (current, max)
            } catch let error as DDCError {
                readError = error
                try await Task.sleep(nanoseconds: readSleepTime)
            }
        } while readError != nil && attemptCount <= attempts

        if let error = readError {
            throw error
        }
    }

    private func write(command: DDC.Command, value: UInt16) async throws {
        guard let ioAVService = service.service else {
            throw DDCError.serviceUnavailable
        }
        let writeSleepTime = UInt64(0.01 * 1000 * 1000 * 1000) // 0.01 seconds in nanoseconds
        let attempts = 3

        let send: [UInt8] = [command.rawValue, UInt8(value >> 8), UInt8(value & 255)]

        var paddedSend = [UInt8(0x80 | (send.count + 1)), UInt8(send.count)] + send + [0]
        paddedSend[paddedSend.count - 1] = paddedSend.checksum(
            initial: send.count == 1 ? 0x6E : 0x6E ^ 0x51,
            range: ClosedRange<Int>(uncheckedBounds: (0, paddedSend.count - 2))
        )

        var writeError: DDCError?
        var attemptCount = 0
        repeat {
            do {
                attemptCount += 1
                try writeI2COnQueue(with: ioAVService, inputBuffer: &paddedSend, inputBufferSize: UInt32(paddedSend.count))
            } catch let error as DDCError {
                writeError = error
                try await Task.sleep(nanoseconds: writeSleepTime)
            }
        } while writeError != nil && attemptCount <= attempts

        if let error = writeError {
            throw error
        }
    }

    private func readI2COnQueue(
        with service: IOAVService,
        chipAddress: UInt32 = 0x37,
        dataAddress: UInt32 = 0x51
    ) throws -> [UInt8] {
        var reply = [UInt8](repeating: 0, count: 11)
        let success = IOAVServiceReadI2C(service, chipAddress, dataAddress, &reply, UInt32(reply.count)) == 0
        if !success {
            throw DDCError.readFailure
        }

        if reply.checksum(initial: 0x50, range: ClosedRange(uncheckedBounds: (0, reply.count - 2))) != reply[reply.count - 1] {
            throw DDCError.checksumValidationFailed
        }

        return reply
    }

    private func writeI2COnQueue(
        with service: IOAVService,
        chipAddress: UInt32 = 0x37,
        dataAddress: UInt32 = 0x51,
        inputBuffer: UnsafeMutableRawPointer,
        inputBufferSize: UInt32
    ) throws {
        if IOAVServiceWriteI2C(service, chipAddress, dataAddress, inputBuffer, inputBufferSize) == 0 {
            return
        } else {
            throw DDCError.writeFailure
        }
    }
}

extension ARMDDC: DDCControlling {
    func readBrightness() async -> BrightnessReading {
        do {
            let (current, max) = try await read(command: .brightness)
            guard max != 0 else {
                return .failure(BrightnessReadError.readError(displayMetadata: displayID.metadata, original: nil))
            }
            return .success(Float(current) / Float(max))
        } catch {
            return .failure(BrightnessReadError.readError(displayMetadata: displayID.metadata, original: error))
        }
    }

    func readDisplayName() -> String {
        service.productName
    }
}

extension ARMDDC {
    @available(*, deprecated, message: "Do not use. Use async/await instead")
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
