//
// Created by Sebastian Wild on 8/5/22.
// Copyright (c) 2022 Sebastian Wild. All rights reserved.
//

import Foundation
import XCTest

@testable import Transitions

final class I2CIOServiceTests: XCTestCase {
    func testWrite() throws {
        let sut = I2CIOService(
            write: { chipAddress, dataAddress, buffer, bufferSize in
                XCTAssertEqual(chipAddress, 1)
                XCTAssertEqual(dataAddress, 2)
                XCTAssertEqual(buffer, [1, 2])
                XCTAssertEqual(bufferSize, 2)

                return 0
            },
            read: { _, _, _, _ in 0 }
        )

        try sut.write(chipAddress: 1, dataAddress: 2, inputBuffer: [1, 2])
    }

    func testWrite_Error() {
        let sut = I2CIOService(
            write: { _, _, _, _ in
                2 // any return code that's not 0 is an error
            },
            read: { _, _, _, _ in 0 }
        )

        do {
            try sut.write(chipAddress: 1, dataAddress: 1, inputBuffer: [1, 2])
            XCTFail("Call should have thrown!")
        } catch let ddcError as DDCError {
            XCTAssertEqual(ddcError, DDCError.writeFailure)
        } catch {
            XCTFail("Incorrect error type thrown!")
        }
    }

    func testRead() throws {
        let sut = I2CIOService(
            write: { _, _, _, _ in
                0
            },
            read: { chipAddress, dataAddress, buffer, bufferSize in
                XCTAssertEqual(chipAddress, 1)
                XCTAssertEqual(dataAddress, 2)
                XCTAssertEqual(buffer, [0, 0])
                XCTAssertEqual(bufferSize, 2)

                buffer = [1, 2]

                return 0
            }
        )

        XCTAssertEqual(
            try sut.read(chipAddress: 1, dataAddress: 2, outputBufferSize: 2),
            [1, 2]
        )
    }

    func testRead_Error() {
        let sut = I2CIOService(
            write: { _, _, _, _ in
                0
            },
            read: { _, _, _, _ in
                -1
            }
        )

        do {
            _ = try sut.read(chipAddress: 1, dataAddress: 1, outputBufferSize: 2)
            XCTFail("Call should have thrown!")
        } catch let ddcError as DDCError {
            XCTAssertEqual(ddcError, DDCError.readFailure)
        } catch {
            XCTFail("Incorrect error type thrown!")
        }
    }
}
