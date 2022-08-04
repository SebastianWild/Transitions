//
// Created by Sebastian Wild on 8/2/22.
// Copyright (c) 2022 Sebastian Wild. All rights reserved.
//

import Foundation

/// Wrapper to read and write DDC over I2C.
struct I2CIOService: I2CIOServiceProviding {
    let service: IOAVService

    init(with service: IOAVService) {
        self.service = service
    }

    func write(chipAddress: UInt32, dataAddress: UInt32, inputBuffer: [UInt8]) throws {
        var input = inputBuffer
        let code = IOAVServiceWriteI2C(service, chipAddress, dataAddress, &input, UInt32(inputBuffer.count))

        guard code == 0 else {
            throw DDCError.writeFailure
        }
    }

    func read(chipAddress: UInt32, dataAddress: UInt32, outputBufferSize: UInt32) throws -> [UInt8] {
        var output = [UInt8](repeating: 0, count: Int(outputBufferSize))
        let code = IOAVServiceReadI2C(service, chipAddress, dataAddress, &output, outputBufferSize)

        guard code == 0 else {
            throw DDCError.readFailure
        }

        return output
    }
}
