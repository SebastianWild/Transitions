//
// Created by Sebastian Wild on 8/2/22.
// Copyright (c) 2022 Sebastian Wild. All rights reserved.
//

import Foundation

protocol I2CIOServiceProviding {
    init(with service: IOAVService)

    func write(chipAddress: UInt32, dataAddress: UInt32, inputBuffer: [UInt8]) throws
    func read(chipAddress: UInt32, dataAddress: UInt32, outputBufferSize: UInt32) throws -> [UInt8]
}
