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
    typealias IORegUtil = (CGDirectDisplayID) -> IORegService?

    /// Optional param used for error reporting purposes
    private let displayMetadata: DisplayMetadata?
    private let service: I2CIOServiceProviding
    private var readingCancellable: AnyCancellable?

    init?(
        for displayID: CGDirectDisplayID
    ) {
        displayMetadata = displayID.metadata
        guard let service = IORegUtils.service(for: displayID) else { return nil }
        guard let ioAVService = service.avService else { return nil }
        self.service = I2CIOService(with: ioAVService)
    }

    init(
        service: I2CIOServiceProviding
    ) {
        displayMetadata = nil
        self.service = service
    }

    private func read(command: DDC.Command, tries _: UInt8 = 3, minReplyDelay _: UInt32 = 10000) async throws -> (current: UInt16, max: UInt16) {
        let readSleepTime = UInt64(0.01 * 1000 * 1000 * 1000) // 0.01 seconds in nanoseconds
        let attempts = 3

        let bytes = DDCMessage(command: command)

        var readError: DDCError?
        var attemptCount = 0
        repeat {
            do {
                attemptCount += 1
                log.debug("Writing DDC command: \(command.rawValue), with send: \(bytes)")
                try writeI2COnQueue(inputBuffer: bytes)
                try await Task.sleep(nanoseconds: readSleepTime)
                log.debug("Reading DDC command: \(command.rawValue), with send: \(bytes)")
                let reply = try readI2COnQueue()
                log.debug("Got DDC raw reply: \(reply)")

                log.debug("Got DDC reply current: \(reply.current) max: \(reply.max)")
                return (reply.current, reply.max)
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
        let writeSleepTime = UInt64(0.01 * 1000 * 1000 * 1000) // 0.01 seconds in nanoseconds
        let attempts = 3

        let bytes = DDCMessage(command: command, value: value)

        var writeError: DDCError?
        var attemptCount = 0
        repeat {
            do {
                attemptCount += 1
                log.debug("Writing DDC command: \(command.rawValue), with value: \(value)")
                try writeI2COnQueue(inputBuffer: bytes)
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
        chipAddress: UInt32 = 0x37,
        dataAddress: UInt32 = 0x51
    ) throws -> [UInt8] {
        var reply = [UInt8](repeating: 0, count: 11)
        reply = try service.read(chipAddress: chipAddress, dataAddress: dataAddress, outputBufferSize: UInt32(reply.count))

        guard reply.isValid else {
            throw DDCError.checksumValidationFailed
        }

        return reply
    }

    private func writeI2COnQueue(
        chipAddress: UInt32 = 0x37,
        dataAddress: UInt32 = 0x51,
        inputBuffer: [UInt8]
    ) throws {
        try service.write(chipAddress: chipAddress, dataAddress: dataAddress, inputBuffer: inputBuffer)
    }
}

extension ARMDDC: DDCControlling {
    func readBrightness() async -> BrightnessReading {
        do {
            let (current, max) = try await read(command: .brightness)
            guard max != 0 else {
                log.error("Got < 0 max brightness from DDC.")
                return .failure(BrightnessReadError.readError(displayMetadata: displayMetadata, original: nil))
            }
            return .success(Float(current) / Float(max))
        } catch {
            log.error("Error when reading brightness: \(error.localizedDescription)")
            return .failure(BrightnessReadError.readError(displayMetadata: displayMetadata, original: error))
        }
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
