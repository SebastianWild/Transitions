//
// Created by Sebastian Wild on 8/5/22.
// Copyright (c) 2022 Sebastian Wild. All rights reserved.
//

import Foundation

typealias DDCReply = [UInt8]

// MARK: - Reply max and current values

extension DDCReply {
    var current: UInt16 {
        UInt16(self[8]) * 256 + UInt16(self[9])
    }

    var max: UInt16 {
        UInt16(self[6]) * 256 + UInt16(self[7])
    }
}

// MARK: - Verification & Checksum

extension DDCReply {
    /// For DDC replies, that initial byte to use for the checksum process.
    static var initial: UInt8 { 0x50 }
    /// Check if the array contains a valid DDC response message.
    ///
    /// Calculates the checksum, and compares it to the last byte of the array.
    var isValid: Bool {
        checksum(initial: Self.initial, range: ClosedRange(uncheckedBounds: (0, count - 2))) == self[count - 1]
    }

    /// Calculate the checksum of the array in accordance with DDC response messages.
    ///
    /// - Parameters:
    ///   - initial: Byte to start the checksum process with
    ///   - range: Range of bytes that should be used to calculate the checksum
    /// - Returns: Byte that should be placed in the last position of the array
    func checksum(initial: UInt8 = Self.initial, range: ClosedRange<Int>) -> UInt8 {
        var check = initial
        for index in range {
            check ^= self[index]
        }

        return check
    }
}
