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

actor ARMDDC: Loggable {
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
            log.warning("Attempted to read from DDC service that is unavailable")
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
                log.debug("Writing DDC command: \(command.rawValue), with send: \(send)")
                try writeI2COnQueue(with: ioAVService, inputBuffer: &paddedSend, inputBufferSize: UInt32(paddedSend.count))
                try await Task.sleep(nanoseconds: readSleepTime)
                log.debug("Reading DDC command: \(command.rawValue), with send: \(send)")
                let reply = try readI2COnQueue(with: ioAVService)
                log.debug("Got DDC raw reply: \(reply)")

                let max = UInt16(reply[6]) * 256 + UInt16(reply[7])
                let current = UInt16(reply[8]) * 256 + UInt16(reply[9])
                log.debug("Got DDC reply current: \(current) max: \(max)")
                return (current, max)
            } catch let error as DDCError {
                readError = error
                log.warning("Error when reading from DDC. Attempt \(attemptCount) of \(attempts). Error: \(error.localizedDescription)")
                try await Task.sleep(nanoseconds: readSleepTime)
            }
        } while readError != nil && attemptCount <= attempts

        if let error = readError {
            log.error("Error when reading from DDC after multiple attempts. Error: \(error.localizedDescription)")
            throw error
        }
    }

    private func write(command: DDC.Command, value: UInt16) async throws {
        guard let ioAVService = service.service else {
            log.warning("Attempted to write to DDC service that is unavailable")
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
                log.debug("Writing DDC command: \(command.rawValue), with value: \(value)")
                try writeI2COnQueue(with: ioAVService, inputBuffer: &paddedSend, inputBufferSize: UInt32(paddedSend.count))
                log.debug("Wrote DDC command: \(command.rawValue), with value: \(value)")
            } catch let error as DDCError {
                writeError = error
                log.warning("Error when writing to DDC. Attempt \(attemptCount) of \(attempts). Error: \(error.localizedDescription)")
                try await Task.sleep(nanoseconds: writeSleepTime)
            }
        } while writeError != nil && attemptCount <= attempts

        if let error = writeError {
            log.error("Error when writing to DDC after multiple attempts. Error: \(error.localizedDescription)")
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
                log.error("Got < 0 max brightness from DDC.")
                return .failure(BrightnessReadError.readError(displayMetadata: displayID.metadata, original: nil))
            }
            return .success(Float(current) / Float(max))
        } catch {
            log.error("Error when reading brightness: \(error.localizedDescription)")
            return .failure(BrightnessReadError.readError(displayMetadata: displayID.metadata, original: error))
        }
    }

    func readDisplayName() -> String {
        service.productName
    }
}

extension ARMDDC {
    enum DDCError: Error, LocalizedError {
        case checksumValidationFailed
        case serviceUnavailable
        case writeFailure
        case readFailure

        var localizedDescription: String {
            switch self {
            case .checksumValidationFailed:
                return "DDC checksum validation failed"
            case .serviceUnavailable:
                return "DDC service unavailable"
            case .writeFailure:
                return "DDC write failed"
            case .readFailure:
                return "DDC read failed"
            }
        }
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

extension DDC.Command: CustomDebugStringConvertible {
    public var debugDescription: String {
        if case .brightness = self {
            return ".brightness"
        } else {
            return "\(rawValue)"
        }
    }
}
