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
        XCTAssertEqual(LevelDB.version.major, 1, "Expected majorVersion to be \(1) but got \(LevelDB.version.major)")
        XCTAssertEqual(LevelDB.version.minor, 23, "Expected minorVersion to be \(23) but got \(LevelDB.version.minor)")
    }

    func testRemoveKey() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)

        let key = "DataKey1".data(using: .utf8)!
        let value = "DataValue1".data(using: .utf8)!

        //
        try levelDB.setValue(value, forKey: key)
        let readValue1: Data? = try levelDB.value(for: key)
        XCTAssertEqual(readValue1, value)

        try levelDB.removeValue(forKey: key)
        let readValue2: Data? = try levelDB.value(for: key)
        XCTAssertNil(readValue2)
    }

    func testStringKeys() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)

        //
        let dataValue = "DataValue1".data(using: .utf8)!

        try levelDB.setValue(dataValue, forKey: "DataKey1")
        try levelDB.setValue("Value1", forKey: "StringKey1")

        //
        let value1: Data? = try levelDB.value(for: "DataKey1")
        XCTAssertEqual(value1, dataValue)
        let value1B: Data? = levelDB["DataKey1"]
        XCTAssertEqual(value1B, dataValue)

        let value2: String? = try levelDB.value(for: "StringKey1")
        XCTAssertEqual(value2, "Value1")
        let value2B: String? = levelDB["StringKey1"]
        XCTAssertEqual(value2B, "Value1")

        //
        try levelDB.removeValue(forKey: "DataKey1")
        let value1C: Data? = levelDB["DataKey1"]
        XCTAssertNil(value1C)
    }

    func testLosslessStringConvertibleValues() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)

        try levelDB.setValue(1, forKey: "Key1")
        try levelDB.setValue(2.0, forKey: "Key2")
        try levelDB.setValue("S", forKey: "Key3")

        let value1: Int? = try levelDB.value(for: "Key1")
        XCTAssertEqual(value1, 1)
        let value1B: Int? = levelDB["Key1"]
        XCTAssertEqual(value1B, 1)

        let value2: Double? = try levelDB.value(for: "Key2")
        XCTAssertEqual(value2, 2.0)

        let value3: String? = try levelDB.value(for: "Key3")
        XCTAssertEqual(value3, "S")
    }

    func testCodableValues() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        //
        let value: [Int: String] = [123456: "Test"]
        try levelDB.setValue(value, forKey: "EncodedKey1", encoder: encoder)

        //
        let decodedValue: [Int: String]? = try levelDB.value(for: "EncodedKey1", decoder: decoder)
        XCTAssertEqual(decodedValue, value)
    }

    func testWriteBatch() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)

        //
        let value1 = "DataValue1".data(using: .utf8)!
        let value2 = "DataValue2".data(using: .utf8)!

        try levelDB.writeBatch { batch in
            try batch.setValue(value1, forKey: "Key1")
            try batch.setValue(value2, forKey: "Key2")
            try batch.removeValue(forKey: "Key1")
        }

        let value1B: Data? = levelDB["Key1"]
        XCTAssertNil(value1B)

        let value2B: Data? = levelDB["Key2"]
        XCTAssertEqual(value2B, value2)
    }

    func testClearWriteBatch() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)

        //
        try levelDB.setValue("Key1Value1", forKey: "Key1")

        try levelDB.writeBatch { batch in
            try batch.setValue("Key1Value2", forKey: "Key1")
            try batch.setValue("Key3Value1", forKey: "Key3")

            batch.clear()

            try batch.setValue("Key2Value1", forKey: "Key2")
        }

        let value1: String? = levelDB["Key1"]
        XCTAssertEqual(value1, "Key1Value1")

        let value2: String? = levelDB["Key3"]
        XCTAssertNil(value2)

        let value3: String? = levelDB["Key2"]
        XCTAssertEqual(value3, "Key2Value1")
    }

    func testWriteBatchWithFailure() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)

        //
        try levelDB.setValue("Value1", forKey: "Key1")

        do {
            try levelDB.writeBatch { batch in
                try batch.removeValue(forKey: "Key1")
                throw TestError.noFailure
            }
        } catch TestError.noFailure {
            //
        }

        let value: String? = levelDB["Key1"]
        XCTAssertEqual(value, "Value1")
    }
}

extension DVELevelDBTests {
    enum TestError: Error {
        case noFailure
        case failure
    }

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
