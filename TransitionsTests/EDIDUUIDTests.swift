//
//  TransitionsTests.swift
//  TransitionsTests
//
//  Created by Sebastian Wild on 11/7/21.
//  Copyright © 2021 Sebastian Wild. All rights reserved.
//

@testable import Transitions
import XCTest

class EDIDUUIDTests: XCTestCase {
    let ediduuid = "4C2D9C0F-0000-0000-2B1C-0104B5772278"

    func testGetVendorID() {
        XCTAssertEqual(19501, ediduuid.vendorID)
    }

    func testGetProductID() {
        XCTAssertEqual(3996, ediduuid.productID)
    }

    func testGetManufactureDate() {
        let (week, year) = ediduuid.manufactureDate ?? (-1, -1)
        XCTAssertEqual(week, 43)
        XCTAssertEqual(year, 2018)
    }

    func testGetHorizontalImageSize() {
        XCTAssertEqual(119, ediduuid.horizontalImageSize)
    }

    func testGetVerticalImageSize() {
        XCTAssertEqual(34, ediduuid.verticalImageSize)
    }
}
