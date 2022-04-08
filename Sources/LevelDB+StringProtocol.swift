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
        return try value(forKey: keyData)
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
        try setValue(value, forKey: keyData)
    }

    func removeValue<Key>(
        forKey key: Key,
        keyEncoding: String.Encoding = .utf8,
        options: WriteOptions = .default
    ) throws where Key: StringProtocol {
        guard let keyData = key.data(using: keyEncoding, allowLossyConversion: false) else {
            throw Error(.invalidArgument)
        }
        try removeValue(forKey: keyData)
    }

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

    func compact<Key>(startKey: Key, endKey: Key, keyEncoding: String.Encoding = .utf8) throws where Key: StringProtocol {
        guard let startKeyData = startKey.data(using: keyEncoding, allowLossyConversion: false),
              let endKeyData = endKey.data(using: keyEncoding, allowLossyConversion: false) else {
            throw Error(.invalidArgument)
        }
        compact(startKey: startKeyData, endKey: endKeyData)
    }
}
