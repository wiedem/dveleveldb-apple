// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

open class KeyComparator: LevelDBKeyComparator & LevelDBKeyEncoder {
    public var keyComparatorName: String

    private let stringKeyEncoding: String.Encoding
    private let comparator: (Data, Data) -> ComparisonResult
    private let findShortestSeparator: ((Data, Data) -> Data?)?
    private let findShortSuccessor: ((Data) -> Data?)?

    public init(
        name: String,
        stringKeyEncoding: String.Encoding = .utf8,
        comparator: @escaping (Data, Data) -> ComparisonResult,
        findShortestSeparator: ((Data, Data) -> Data?)? = nil,
        findShortSuccessor: ((Data) -> Data?)? = nil
    ) {
        keyComparatorName = name
        self.stringKeyEncoding = stringKeyEncoding
        self.comparator = comparator
        self.findShortestSeparator = findShortestSeparator
        self.findShortSuccessor = findShortSuccessor
    }

    public func compare(_ lhs: Data, with rhs: Data) -> ComparisonResult {
        comparator(lhs, rhs)
    }

    public func findShortestSeparator(startKey: Data, limitKey: Data) -> Data? {
        findShortestSeparator?(startKey, limitKey)
    }

    public func findShortSuccessor(forKey key: Data) -> Data? {
        findShortSuccessor?(key)
    }

    public func encodeKey<Key>(_ key: Key) throws -> Data where Key: StringProtocol {
        guard let keyData = key.data(using: stringKeyEncoding, allowLossyConversion: false) else {
            throw LevelDBError.keyEncodingFailed
        }
        return keyData
    }
}
