// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB {
    func value<Key, Value>(
        forKey key: Key,
        encoding: String.Encoding = .utf8,
        options: ReadOptions = .default
    ) throws -> Value? where Key: StringProtocol, Value: LosslessStringConvertible {
        guard let valueData: Data = try value(forKey: key, keyEncoding: encoding, options: options) else {
            return nil
        }

        guard let valueString = String(data: valueData, encoding: encoding),
              let value = Value(valueString) else {
            throw Error(.invalidType)
        }
        return value
    }

    func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key,
        encoding: String.Encoding = .utf8,
        options: WriteOptions = .default
    ) throws where Key: StringProtocol, Value: LosslessStringConvertible {
        guard let valueData = value.description.data(using: encoding, allowLossyConversion: false) else {
            throw Error(.invalidArgument)
        }

        try setValue(valueData, forKey: key, keyEncoding: encoding, options: options)
    }

    subscript<Key, Value>(
        key: Key,
        encoding: String.Encoding = .utf8,
        options: ReadOptions = .default
    ) -> Value? where Key: StringProtocol, Value: LosslessStringConvertible {
        guard let valueData: Data = self[key, encoding, options] else {
            return nil
        }
        guard let valueString = String(data: valueData, encoding: encoding),
              let value = Value(valueString) else {
            fatalError("Error getting value from DB: \(Error(.invalidType))")
        }
        return value
    }
}
