// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB
import XCTest

final class DVELevelDBTests: XCTestCase {
    private static let fileManager: FileManager = .default

    private var directoryUrl: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()

        directoryUrl = Self.createTemporaryDirectory()
    }

    override func tearDownWithError() throws {
        try Self.fileManager.removeItem(at: directoryUrl)
        directoryUrl = nil

        try super.tearDownWithError()
    }

    func testVersion() {
        XCTAssert(LevelDB.majorVersion == 1)
        XCTAssert(LevelDB.minorVersion == 23)
    }

    func testStringKeys() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl, options: .default)

        //
        let dataValue = "DataValue1".data(using: .utf8)!

        try levelDB.setValue(dataValue, forKey: "DataKey1")
        try levelDB.setValue("Value1", forKey: "StringKey1")

        //
        let value1: Data? = try levelDB.value(for: "DataKey1")
        XCTAssert(value1 == dataValue)
        let value1B: Data? = levelDB["DataKey1"]
        XCTAssert(value1B == dataValue)

        let value2: String? = try levelDB.value(for: "StringKey1")
        XCTAssert(value2 == "Value1")
        let value2B: String? = levelDB["StringKey1"]
        XCTAssert(value2B == "Value1")
    }

    func testCodableValue() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl, options: .default)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        //
        let value: [Int: String] = [123456: "Test"]
        try levelDB.setValue(value, forKey: "EncodedKey1", encoder: encoder)

        //
        let decodedValue: [Int: String]? = try levelDB.value(for: "EncodedKey1", decoder: decoder)
        XCTAssert(decodedValue == value)
    }
}

extension DVELevelDBTests {
    class func createTemporaryDirectory() -> URL {
        let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return try! fileManager.url(
            for: .itemReplacementDirectory,
            in: .userDomainMask,
            appropriateFor: url,
            create: true
        )
    }
}
