// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB where KeyComparator: LevelDBKeyEncoder {
    func value<Key>(
        forKey key: Key,
        options: ReadOptions = .default
    ) throws -> Data? where Key: StringProtocol {
        let keyData = try keyComparator.encodeKey(key)
        return try value(forKey: keyData, options: options)
    }

    func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key,
        options: WriteOptions = .default
    ) throws where Key: StringProtocol, Value: ContiguousBytes {
        let keyData = try keyComparator.encodeKey(key)
        try setValue(value, forKey: keyData, options: options)
    }

    func removeValue<Key>(
        forKey key: Key,
        options: WriteOptions = .default
    ) throws where Key: StringProtocol {
        let keyData = try keyComparator.encodeKey(key)
        try removeValue(forKey: keyData, options: options)
    }

    func getApproximateSizes<Key>(forKeyRanges keyRanges: [Range<Key>]) throws -> [UInt64] where Key: StringProtocol {
        let dataKeyRanges = try keyRanges.map { range -> (Data, Data) in
            guard range.isEmpty == false else {
                throw LevelDBError.invalidKeyRange
            }

            let startKeyData = try keyComparator.encodeKey(range.lowerBound)
            let limitKeyData = try keyComparator.encodeKey(range.upperBound)

            guard range.contains(range.upperBound) == false else {
                guard let limitSuccessor = keyComparator.findShortestSuccessor(forKey: limitKeyData) else {
                    throw LevelDBError.invalidKeyRange
                }
                return (startKeyData, limitSuccessor)
            }
            return (startKeyData, limitKeyData)
        }
        return getApproximateSizes(forKeyRanges: dataKeyRanges)
    }

    func getApproximateSizes<Key>(forKeyRanges keyRanges: [ClosedRange<Key>]) throws -> [UInt64] where Key: StringProtocol {
        let dataKeyRanges = try keyRanges.map { range -> (Data, Data) in
            let startKeyData = try keyComparator.encodeKey(range.lowerBound)
            let limitKeyData = try keyComparator.encodeKey(range.upperBound)

            guard let limitSuccessor = keyComparator.findShortestSuccessor(forKey: limitKeyData) else {
                throw LevelDBError.invalidKeyRange
            }
            return (startKeyData, limitSuccessor)
        }
        return getApproximateSizes(forKeyRanges: dataKeyRanges)
    }

    func compact<Key>(startKey: Key) throws where Key: StringProtocol {
        let keyData = try keyComparator.encodeKey(startKey)
        compact(startKey: keyData)
    }

    func compact<Key>(endKey: Key) throws where Key: StringProtocol {
        let keyData = try keyComparator.encodeKey(endKey)
        compact(endKey: keyData)
    }

    func compact<Key>(keyRange: ClosedRange<Key>) throws where Key: StringProtocol {
        let startKeyData = try keyComparator.encodeKey(keyRange.lowerBound)
        let endKeyData = try keyComparator.encodeKey(keyRange.upperBound)
        compact(startKey: startKeyData, endKey: endKeyData)
    }
}

public extension LevelDB where KeyComparator: LevelDBKeyEncoder {
    subscript<Key>(key: Key, options: ReadOptions = .default) -> Data? where Key: StringProtocol {
        do {
            return try value(forKey: key, options: options)
        } catch {
            fatalError("Error getting value from DB: \(error)")
        }
    }
}
