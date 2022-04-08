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
        let readValue1: Data? = try levelDB.value(forKey: key)
        XCTAssertEqual(readValue1, value)

        try levelDB.removeValue(forKey: key)
        let readValue2: Data? = try levelDB.value(forKey: key)
        XCTAssertNil(readValue2)
    }

    func testStringKeys() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)

        //
        let dataValue = "DataValue1".data(using: .utf8)!

        try levelDB.setValue(dataValue, forKey: "DataKey1")
        try levelDB.setValue("Value1", forKey: "StringKey1")

        //
        let value1: Data? = try levelDB.value(forKey: "DataKey1")
        XCTAssertEqual(value1, dataValue)
        let value1B: Data? = levelDB["DataKey1"]
        XCTAssertEqual(value1B, dataValue)

        let value2: String? = try levelDB.value(forKey: "StringKey1")
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

        let value1: Int? = try levelDB.value(forKey: "Key1")
        XCTAssertEqual(value1, 1)
        let value1B: Int? = levelDB["Key1"]
        XCTAssertEqual(value1B, 1)

        let value2: Double? = try levelDB.value(forKey: "Key2")
        XCTAssertEqual(value2, 2.0)

        let value3: String? = try levelDB.value(forKey: "Key3")
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
        let decodedValue: [Int: String]? = try levelDB.value(forKey: "EncodedKey1", decoder: decoder)
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

    func testKeyComparator() throws {
        // A simple key comparator implementation for UTF-8 encoded string keys.
        let keyComparator = LevelDB.KeyComparator(name: "Test") { key1, key2 in
            // We simply compare the keys as strings.
            let key1String = String(data: key1, encoding: .utf8)!
            let key2String = String(data: key2, encoding: .utf8)!
            return key1String.compare(key2String)
        } findShortestSuccessor: { key in
            // The method to search for the shortest successor
            let keyString = String(data: key, encoding: .utf8)!
            guard let asciiValue = keyString.first!.asciiValue else {
                return nil
            }
            let nextAsciiValue = asciiValue < 255 ? asciiValue + 1 : asciiValue
            let successorChar = Character(UnicodeScalar(nextAsciiValue))
            return String(successorChar).data(using: .utf8, allowLossyConversion: false)
        }

        let levelDB = try LevelDB(directoryURL: directoryUrl, keyComparator: keyComparator)

        try levelDB.setValue("Value1", forKey: "A1")
        try levelDB.setValue("Value2", forKey: "B1")

        // Compact will cause outstanding write operations to be performed and the key comparator to be called.
        levelDB.compact()

        let value1: String? = try levelDB.value(forKey: "A1")
        XCTAssertEqual(value1, "Value1")
        let value2: String? = try levelDB.value(forKey: "B1")
        XCTAssertEqual(value2, "Value2")
    }

    func testReadWithSnapshot() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)

        try levelDB.setValue("Value1", forKey: "A1")
        try levelDB.setValue("Value2", forKey: "B1")
        try levelDB.setValue("Value3", forKey: "C1")

        let snapshot = levelDB.createSnapshot()

        try levelDB.setValue("Value2B", forKey: "B1")
        try levelDB.removeValue(forKey: "C1")
        try levelDB.setValue("Value4", forKey: "D1")

        let value1: String? = try levelDB.value(forKey: "A1", options: .usingSnapshot(snapshot))
        XCTAssertEqual(value1, "Value1")
        let value2: String? = try levelDB.value(forKey: "B1", options: .usingSnapshot(snapshot))
        XCTAssertEqual(value2, "Value2")
        let value3: String? = try levelDB.value(forKey: "C1", options: .usingSnapshot(snapshot))
        XCTAssertEqual(value3, "Value3")
        let value4: String? = try levelDB.value(forKey: "D1", options: .usingSnapshot(snapshot))
        XCTAssertNil(value4)
    }

    func testCompact() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)

        try levelDB.setValue("Value1", forKey: "A1")
        try levelDB.setValue("Value2", forKey: "B1")
        try levelDB.setValue("Value3", forKey: "C1")

        levelDB.compact()
    }

    func testCompactWithStartKey() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)

        try levelDB.setValue("Value1", forKey: "A1")
        try levelDB.setValue("Value2", forKey: "B1")
        try levelDB.setValue("Value3", forKey: "C1")

        try levelDB.compact(startKey: "B1")
    }

    func testCompactWithEndKey() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)

        try levelDB.setValue("Value1", forKey: "A1")
        try levelDB.setValue("Value2", forKey: "B1")
        try levelDB.setValue("Value3", forKey: "C1")

        try levelDB.compact(endKey: "B1")
    }

    func testCompactWithStartAndEndKey() throws {
        let levelDB = try LevelDB(directoryURL: directoryUrl)

        try levelDB.setValue("Value1", forKey: "A1")
        try levelDB.setValue("Value2", forKey: "B1")
        try levelDB.setValue("Value3", forKey: "C1")

        try levelDB.compact(startKey: "A1", endKey: "B1")
    }
}

extension String {
    func compare(_ other: String) -> ComparisonResult {
        if self == other {
            return .orderedSame
        } else if self < other {
            return .orderedAscending
        }
        return .orderedDescending
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
