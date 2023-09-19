// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB
import DVELevelDB_ObjC
import XCTest

final class KeyRangeTests: XCTestCase {
    func testEquality() {
        let startKey = "A".data(using: .utf8)!
        let endKey = "Z".data(using: .utf8)!

        let keyRange1 = CLevelDB.KeyRange(startKey: startKey, limitKey: endKey)
        let keyRange2 = CLevelDB.KeyRange(startKey: startKey, limitKey: endKey)

        XCTAssertEqual(keyRange1, keyRange2)
    }

    func testInequality() {
        let startKey1 = "A".data(using: .utf8)!
        let endKey1 = "Z".data(using: .utf8)!
        let startKey2 = "AA".data(using: .utf8)!
        let endKey2 = "ZZ".data(using: .utf8)!

        let keyRange1 = CLevelDB.KeyRange(startKey: startKey1, limitKey: endKey1)
        let keyRange2 = CLevelDB.KeyRange(startKey: startKey2, limitKey: endKey2)
        let keyRange3 = CLevelDB.KeyRange(startKey: startKey1, limitKey: endKey2)
        let keyRange4 = CLevelDB.KeyRange(startKey: startKey2, limitKey: endKey1)

        XCTAssertNotEqual(keyRange1, keyRange2)
        XCTAssertNotEqual(keyRange1, keyRange3)
        XCTAssertNotEqual(keyRange1, keyRange4)
        XCTAssertNotEqual(keyRange2, keyRange3)
        XCTAssertNotEqual(keyRange2, keyRange4)
        XCTAssertNotEqual(keyRange3, keyRange4)
    }
}
