// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB
import XCTest

final class DVELevelDBTests: XCTestCase {
    func testVersion() {
        XCTAssert(LevelDB.majorVersion == 1)
        XCTAssert(LevelDB.minorVersion == 23)
    }
}
