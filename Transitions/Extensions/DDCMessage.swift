//
// Created by Sebastian Wild on 8/5/22.
// Copyright (c) 2022 Sebastian Wild. All rights reserved.
//

import DDC
import Foundation

typealias DDCMessage = [UInt8]

extension DDCMessage {
    init(command: DDC.Command) {
        self.init()
        toBytes(command: command, with: nil)
    }

    init(command: DDC.Command, value: UInt16) {
        self.init()
        toBytes(command: command, with: value)
    }

    private mutating func toBytes(command: DDC.Command, with value: UInt16?) {
        let send: [UInt8]
        if let val = value {
            send = [command.rawValue, UInt8(val >> 8), UInt8(val & 255)]
        } else {
            send = [command.rawValue]
        }

        var paddedSend = [UInt8(0x80 | (send.count + 1)), UInt8(send.count)] + send + [0]
        paddedSend[paddedSend.count - 1] = paddedSend.checksum(
            initial: send.count == 1 ? 0x6E : 0x6E ^ 0x51,
            range: ClosedRange<Int>(uncheckedBounds: (0, paddedSend.count - 2))
        )
        self = paddedSend
    }
}
