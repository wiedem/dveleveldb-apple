// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

open class KeyComparator: LevelDBKeyComparator & LevelDBKeyEncoder {
    public var keyComparatorName: String

    private let stringKeyEncoding: String.Encoding
    private let comparator: (Data, Data) -> ComparisonResult
    private let findShortestSeparator: ((Data, Data) -> Data?)?
    private let findShortestSuccessor: ((Data) -> Data?)?

    public init(
        name: String,
        stringKeyEncoding: String.Encoding = .utf8,
        comparator: @escaping (Data, Data) -> ComparisonResult,
        findShortestSeparator: ((Data, Data) -> Data?)? = nil,
        findShortestSuccessor: ((Data) -> Data?)? = nil
    ) {
        keyComparatorName = name
        self.stringKeyEncoding = stringKeyEncoding
        self.comparator = comparator
        self.findShortestSeparator = findShortestSeparator
        self.findShortestSuccessor = findShortestSuccessor
    }

    public func compare(_ lhs: Data, with rhs: Data) -> ComparisonResult {
        comparator(lhs, rhs)
    }

    public func findShortestSeparator(startKey: Data, limitKey: Data) -> Data? {
        findShortestSeparator?(startKey, limitKey)
    }

    public func findShortestSuccessor(forKey key: Data) -> Data? {
        findShortestSuccessor?(key)
    }

    public func encodeKey<Key>(_ key: Key) throws -> Data where Key: StringProtocol {
        guard let keyData = key.data(using: stringKeyEncoding, allowLossyConversion: false) else {
            throw CLevelDB.Error(.invalidArgument)
        }
        return keyData
    }
}
