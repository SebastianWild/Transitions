//
//  EDIDUUID.swift
//  Transitions
//
//  Created by Sebastian Wild on 10/24/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

import Foundation

typealias EDIDUUID = String

extension EDIDUUID {
    enum Component {
        case vendorID
        case productID
        case manufactureYear
        case manufactureWeek
        case horizontalImageSize
        case verticalImageSize
    }

    //// Hex-encoded strings
    subscript(_ component: Component) -> String? {
        let range: Range<String.Index>?
        switch component {
        case .vendorID:
            range = vendorIDRange
        case .productID:
            range = productIDRange
        case .manufactureYear:
            range = manufactureYearRange
        case .manufactureWeek:
            range = manufactureWeekRange
        case .horizontalImageSize:
            range = horizontalImageSizeRange
        case .verticalImageSize:
            range = verticalImageSizeRange
        }

        guard let range = range else { return nil }
        return String(
            self[range]
        )
    }

    /// Vendor ID
    ///
    /// Ex: Samsung is 19501
    var vendorID: Int? {
        guard let vendorIDHexString = self[.vendorID]?.uppercased() else { return nil }
        return Int(vendorIDHexString, radix: 16)
    }

    /// Product ID
    ///
    /// Note that the format is LSB/MSB (least significant bit first)
    /// We can get there by byte flipping then converting to decimal
    /// Ex. Samsung CRG9 is 3996
    var productID: Int? {
        guard let hexSubstring = self[.productID] else { return nil }

        let hex = String(hexSubstring)
        var from = hex.startIndex
        let end = hex.endIndex

        // Naive byte swap implementation below.
        // We cannot simply call `.byteSwapped` on the integer representation of our hex string,
        // as that assumes a certain byte width swap - ex. 4 bytes on 32 bit systems. This gives a widely incorrect value.

        // Instead we need to do a minimum byte swap.
        // The naive approach is to parse the hex string two characters (one byte) at a time and reverse this collection. Ta-da!
        // Not sure if this approach can fall flat but given that the EDIDUUID has a constant width,
        // there should be no zero padding issues.
        var bytes = [String]()

        while from != endIndex {
            guard let to = index(from, offsetBy: 2, limitedBy: end) else { break }

            let byte = String(hex[from ..< to])
            bytes.append(byte)

            from = to
        }

        let decRepresentation = Int(bytes.reversed().joined(), radix: 16)
        return decRepresentation
    }

    var manufactureDate: (week: Int?, year: Int?)? {
        guard
            let manufactureWeekHex = self[.manufactureWeek],
            let manufactureYearHex = self[.manufactureYear]
        else { return nil }

        let week = Int(String(manufactureWeekHex.uppercased()), radix: 16)
        var year = Int(String(manufactureYearHex.uppercased()), radix: 16)

        if let _year = year {
            year = _year + 1990
        }

        return (week, year)
    }

    /// Display horizontal size in centimeters?
    var horizontalImageSize: Int? {
        guard let hexSubstring = self[.horizontalImageSize] else { return nil }
        return Int(String(hexSubstring.uppercased()), radix: 16)
    }

    /// Display vertical size in centimeters?
    var verticalImageSize: Int? {
        guard let hexSubstring = self[.verticalImageSize] else { return nil }
        return Int(String(hexSubstring.uppercased().reversed()), radix: 16)
    }

    private var vendorIDRange: Range<String.Index>? {
        guard let endIndex = index(startIndex, offsetBy: 4, limitedBy: endIndex) else { return nil }

        return startIndex ..< endIndex
    }

    private var productIDRange: Range<String.Index>? {
        guard
            let startIndex = vendorIDRange?.upperBound,
            let endIndex = index(startIndex, offsetBy: 4, limitedBy: endIndex)
        else { return nil }

        return startIndex ..< endIndex
    }

    private var manufactureWeekRange: Range<String.Index>? {
        guard
            let startIndex = index(startIndex, offsetBy: 19, limitedBy: endIndex),
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: endIndex)
        else { return nil }

        return startIndex ..< endIndex
    }

    private var manufactureYearRange: Range<String.Index>? {
        guard
            let startIndex = manufactureWeekRange?.upperBound,
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: endIndex)
        else { return nil }

        return startIndex ..< endIndex
    }

    private var manufactureDateRange: Range<String.Index>? {
        guard
            let lowerBound = manufactureWeekRange?.upperBound,
            let upperBound = manufactureYearRange?.upperBound
        else { return nil }

        return Range(uncheckedBounds: (lowerBound, upperBound))
    }

    private var horizontalImageSizeRange: Range<String.Index>? {
        guard
            let startIndex = index(startIndex, offsetBy: 30, limitedBy: endIndex),
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: endIndex)
        else { return nil }

        return startIndex ..< endIndex
    }

    private var verticalImageSizeRange: Range<String.Index>? {
        guard
            let startIndex = horizontalImageSizeRange?.upperBound,
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: endIndex)
        else { return nil }

        return startIndex ..< endIndex
    }

    private var imageSizeRange: Range<String.Index>? {
        guard
            let startIndex = index(startIndex, offsetBy: 30, limitedBy: endIndex),
            let endIndex = index(startIndex, offsetBy: 4, limitedBy: endIndex)
        else { return nil }

        return startIndex ..< endIndex
    }
}
