// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB
import XCTest

class CodablesLevelDBTests: XCTestCase {
    private static let fileManager: FileManager = .default

    private var directoryUrl: URL!

    enum CodingKeys: String, CodingKey {
        case key1
        case key2
        case key3
    }

    struct TestObject: Codable {
        let stringValue: String
        let intValue: Int
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        directoryUrl = createTemporaryDirectory(fileManager: Self.fileManager)
    }

    override func tearDownWithError() throws {
        try Self.fileManager.removeItem(at: directoryUrl)
        directoryUrl = nil

        try super.tearDownWithError()
    }

    func testAccessWithCodingKeys() throws {
        let valueCoder = LevelDBJSONValueCoder(jsonEncoder: .init(), jsonDecoder: .init())

        let levelDB = try CodablesLevelDB<CodingKeys>(directoryURL: directoryUrl, valueCoder: valueCoder)

        //
        try levelDB.setValue("Test1", forKey: .key1)
        try levelDB.setValue(TestObject(stringValue: "Test2", intValue: 1), forKey: .key2)

        let value1: String? = levelDB[.key1]
        XCTAssertEqual(value1, "Test1")

        let value2: TestObject? = levelDB[.key2]
        XCTAssertNotNil(value2)

        let value3: String? = levelDB[.key3]
        XCTAssertNil(value3)

        //
        try levelDB.removeValue(forKey: .key2)
        let value2B: TestObject? = levelDB[.key2]
        XCTAssertNil(value2B)
    }

    func testInvalidDecoding() throws {
        let valueCoder = LevelDBJSONValueCoder(jsonEncoder: .init(), jsonDecoder: .init())

        let levelDB = try CodablesLevelDB<CodingKeys>(directoryURL: directoryUrl, valueCoder: valueCoder)

        //
        try levelDB.setValue("Test1", forKey: .key1)
        try levelDB.setValue(TestObject(stringValue: "Test2", intValue: 1), forKey: .key2)

        XCTAssertThrowsError(
            try { let _: TestObject? = try levelDB.value(forKey: .key1) }()
        )
        XCTAssertThrowsError(
            try { let _: String? = try levelDB.value(forKey: .key2) }()
        )
    }
}
