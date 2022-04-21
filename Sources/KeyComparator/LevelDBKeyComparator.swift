// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public protocol LevelDBKeyEncoder: AnyObject {
    func encodeKey<Key>(_ key: Key) throws -> Data where Key: StringProtocol
}

public protocol LevelDBKeyComparator: AnyObject {
    var keyComparatorName: String { get }

    func compare(_ lhs: Data, with rhs: Data) -> ComparisonResult
    func findShortestSeparator(startKey: Data, limitKey: Data) -> Data?
    func findShortestSuccessor(forKey key: Data) -> Data?
}

public extension LevelDBKeyComparator {
    func findShortestSeparator(startKey: Data, limitKey: Data) -> Data? { nil }
    func findShortestSuccessor(forKey key: Data) -> Data? { nil }
}

extension BytewiseKeyComparator: LevelDBKeyComparator & LevelDBKeyEncoder {
    public var keyComparatorName: String { name }

    public func compareKeys(key1: Data, key2: Data) -> ComparisonResult {
        compare(key1, with: key2)
    }

    public func findShortestSeparator(startKey: Data, limitKey: Data) -> Data? {
        findShortestSeparator(startKey, limit: limitKey)
    }

    public func findShortestSuccessor(forKey key: Data) -> Data? {
        findShortestSuccessor(key)
    }

    public func encodeKey<Key>(_ key: Key) throws -> Data where Key: StringProtocol {
        guard let keyData = key.data(using: .utf8, allowLossyConversion: false) else {
            throw LevelDBError.keyEncodingFailed
        }
        return keyData
    }
}
