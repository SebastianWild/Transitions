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
    // TODO: Might need to remove the hyphens?
    // Example UUID = 4C2D9C0F-0000-0000-2B1C-0104B5772278
    enum Component {
        case vendorID
        case productID
        case manufactureYear
        case manufactureWeek
        case horizontalImageSize
        case verticalImageSize
    }

    //// Hex-encoded strings
    subscript(_ component: Component) -> String {
        let range: Range<String.Index>
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

        return String(
            self[range]
        )
    }

    /// Vendor ID
    ///
    /// Ex: Samsung is 19501
    var vendorID: Int? {
        Int(self[.vendorID].uppercased(), radix: 16)
    }

    /// Product ID
    ///
    /// Note that the format is LSB/MSB (least significant bit first)
    /// We can get there by byte flipping then converting to decimal
    /// Ex. Samsung CRG9 is 3996
    var productID: Int? {
        Int(String(self[.productID].reversed()), radix: 16)
    }

    // Example UUID = 4C2D9C0F-0000-0000-2B1C-0104B5772278
    var manufactureDate: (week: Int?, year: Int?) {
        let week = Int(String(self[.manufactureWeek].uppercased().reversed()), radix: 16)
        var year = Int(String(self[.manufactureYear].uppercased().reversed()), radix: 16)

        if let _year = year {
            year = _year - 1990
        }

        return (week, year)
    }

    var horizontalImageSize: Int? {
        Int(String(self[.horizontalImageSize].uppercased().reversed()), radix: 16)
    }

    var verticalImageSize: Int? {
        Int(String(self[.verticalImageSize].uppercased().reversed()), radix: 16)
    }

    private var vendorIDRange: Range<String.Index> {
        startIndex ..< index(startIndex, offsetBy: 3)
    }

    private var productIDRange: Range<String.Index> {
        let start = vendorIDRange.upperBound
        return start ..< index(start, offsetBy: 4)
    }

    private var manufactureWeekRange: Range<String.Index> {
        let start = index(startIndex, offsetBy: 19)
        return start ..< index(start, offsetBy: 2)
    }

    private var manufactureYearRange: Range<String.Index> {
        let start = manufactureWeekRange.upperBound
        return start ..< index(start, offsetBy: 2)
    }

    private var manufactureDateRange: Range<String.Index> {
        Range(uncheckedBounds: (manufactureWeekRange.lowerBound, manufactureYearRange.upperBound))
    }

    private var horizontalImageSizeRange: Range<String.Index> {
        let start = index(startIndex, offsetBy: 30)
        return start ..< index(start, offsetBy: 2)
    }

    private var verticalImageSizeRange: Range<String.Index> {
        let start = horizontalImageSizeRange.upperBound
        return start ..< index(start, offsetBy: 2)
    }

    private var imageSizeRange: Range<String.Index> {
        let start = index(startIndex, offsetBy: 30)
        return start ..< index(start, offsetBy: 4)
    }
}
