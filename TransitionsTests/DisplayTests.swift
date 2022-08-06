//
// Created by Sebastian Wild on 8/2/22.
// Copyright (c) 2022 Sebastian Wild. All rights reserved.
//

import Foundation
import XCTest

@testable import Transitions

final class DisplayTests: XCTestCase {
    // MARK: - Extension tests

    func testGetPersistentIdentifier_InternalDisplay() {
        let sut = Preview.MockDisplay(isInternal: true)
        XCTAssertEqual(sut.persistentIdentifier, PersistentIdentifier.internalDisplay)
    }

//    func testGetPersistentIdentifier_FromMetadata() {
//        let sut = Preview.MockDisplay()
//        XCTAssertEqual(sut.persistentIdentifier, PersistentIdentifier.internalDisplay)
//    }
}
