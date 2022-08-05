//
// Created by Sebastian Wild on 8/2/22.
// Copyright (c) 2022 Sebastian Wild. All rights reserved.
//

import Foundation

/// Wrapper to read and write DDC over I2C.
struct I2CIOService: I2CIOServiceProviding {
    typealias I2C = (UInt32, UInt32, inout [UInt8], UInt32) -> Int32

    private let write: I2C
    private let read: I2C

    init(with service: IOAVService) {
        func write(chipAddress: UInt32, dataAddress: UInt32, inputBuffer: inout [UInt8], outputBufferSize: UInt32) -> Int32 {
            IOAVServiceWriteI2C(service, chipAddress, dataAddress, &inputBuffer, UInt32(inputBuffer.count))
        }
        func read(chipAddress: UInt32, dataAddress: UInt32, output: inout [UInt8], outputBufferSize: UInt32) -> Int32 {
            IOAVServiceReadI2C(service, chipAddress, dataAddress, &output, outputBufferSize)
        }

        self.write = write
        self.read = read
    }

    init(
        write: @escaping I2C,
        read: @escaping I2C
    ) {
        self.write = write
        self.read = read
    }

    func write(chipAddress: UInt32, dataAddress: UInt32, inputBuffer: [UInt8]) throws {
        var input = inputBuffer
        let code = write(chipAddress, dataAddress, &input, UInt32(inputBuffer.count))

        guard code == 0 else {
            throw DDCError.writeFailure
        }
    }

    func read(chipAddress: UInt32, dataAddress: UInt32, outputBufferSize: UInt32) throws -> [UInt8] {
        var output = [UInt8](repeating: 0, count: Int(outputBufferSize))
        let code = read(chipAddress, dataAddress, &output, outputBufferSize)

        guard code == 0 else {
            throw DDCError.readFailure
        }

        return output
    }
}
