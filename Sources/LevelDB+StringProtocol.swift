// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB {
    func value<Key>(
        forKey key: Key,
        keyEncoding: String.Encoding = .utf8,
        options: ReadOptions = .default
    ) throws -> Data? where Key: StringProtocol {
        guard let keyData = key.data(using: keyEncoding, allowLossyConversion: false) else {
            throw Error(.invalidArgument)
        }
        return try value(forKey: keyData, options: options)
    }

    func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key,
        keyEncoding: String.Encoding = .utf8,
        options: WriteOptions = .default
    ) throws where Key: StringProtocol, Value: ContiguousBytes {
        guard let keyData = key.data(using: keyEncoding, allowLossyConversion: false) else {
            throw Error(.invalidArgument)
        }
        try setValue(value, forKey: keyData, options: options)
    }

    func removeValue<Key>(
        forKey key: Key,
        keyEncoding: String.Encoding = .utf8,
        options: WriteOptions = .default
    ) throws where Key: StringProtocol {
        guard let keyData = key.data(using: keyEncoding, allowLossyConversion: false) else {
            throw Error(.invalidArgument)
        }
        try removeValue(forKey: keyData, options: options)
    }

    func getApproximateSizes<Key>(
        forKeyRanges keyRanges: [Range<Key>],
        keyEncoding: String.Encoding = .utf8
    ) throws -> [UInt64] where Key: StringProtocol {
        let dataKeyRanges = try keyRanges.map { range -> (Data, Data) in
            guard range.isEmpty == false else {
                throw Error(.invalidArgument)
            }

            guard let startKeyData = range.lowerBound.data(using: keyEncoding, allowLossyConversion: false),
                  let limitKeyData = range.upperBound.data(using: keyEncoding, allowLossyConversion: false) else {
                throw Error(.invalidArgument)
            }

            guard range.contains(range.upperBound) == false else  {
                guard let limitSuccessor = cLevelDB.keyComparator.findShortestSuccessor?(limitKeyData) else {
                    throw Error(.invalidArgument)
                }
                return (startKeyData, limitSuccessor)
            }
            return (startKeyData, limitKeyData)
        }
        return getApproximateSizes(forKeyRanges: dataKeyRanges)
    }

    func getApproximateSizes<Key>(
        forKeyRanges keyRanges: [ClosedRange<Key>],
        keyEncoding: String.Encoding = .utf8
    ) throws -> [UInt64] where Key: StringProtocol {
        let dataKeyRanges = try keyRanges.map { range -> (Data, Data) in
            guard let startKeyData = range.lowerBound.data(using: keyEncoding, allowLossyConversion: false),
                  let limitKeyData = range.upperBound.data(using: keyEncoding, allowLossyConversion: false) else {
                throw Error(.invalidArgument)
            }
            
            guard let limitSuccessor = cLevelDB.keyComparator.findShortestSuccessor?(limitKeyData) else {
                throw Error(.invalidArgument)
            }
            return (startKeyData, limitSuccessor)
        }
        return getApproximateSizes(forKeyRanges: dataKeyRanges)
    }

    func compact<Key>(startKey: Key, keyEncoding: String.Encoding = .utf8) throws where Key: StringProtocol {
        guard let keyData = startKey.data(using: keyEncoding, allowLossyConversion: false) else {
            throw Error(.invalidArgument)
        }
        compact(startKey: keyData)
    }

    func compact<Key>(endKey: Key, keyEncoding: String.Encoding = .utf8) throws where Key: StringProtocol {
        guard let keyData = endKey.data(using: keyEncoding, allowLossyConversion: false) else {
            throw Error(.invalidArgument)
        }
        compact(endKey: keyData)
    }

    func compact<Key>(keyRange: ClosedRange<Key>, keyEncoding: String.Encoding = .utf8) throws where Key: StringProtocol {
        guard let startKeyData = keyRange.lowerBound.data(using: keyEncoding, allowLossyConversion: false),
              let endKeyData = keyRange.upperBound.data(using: keyEncoding, allowLossyConversion: false) else {
            throw Error(.invalidArgument)
        }
        compact(startKey: startKeyData, endKey: endKeyData)
    }
}

public extension LevelDB {
    subscript<Key>(
        key: Key,
        keyEncoding: String.Encoding = .utf8,
        options: ReadOptions = .default
    ) -> Data? where Key: StringProtocol {
        do {
            return try value(forKey: key, keyEncoding: keyEncoding, options: options)
        } catch {
            fatalError("Error getting value from DB: \(error)")
        }
    }
}
