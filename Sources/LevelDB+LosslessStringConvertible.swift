// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB {
    func value<Key, Value>(
        forKey key: Key,
        encoding: String.Encoding = .utf8,
        options: ReadOptions = .default
    ) throws -> Value? where Key: ContiguousBytes, Value: LosslessStringConvertible {
        guard let valueData: Data = try value(forKey: key, options: options) else {
            return nil
        }

        guard let valueString = String(data: valueData, encoding: encoding),
              let value = Value(valueString)
        else {
            throw LevelDBError.valueConversionFailed
        }
        return value
    }

    func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key,
        encoding: String.Encoding = .utf8,
        options: WriteOptions = .default
    ) throws where Key: ContiguousBytes, Value: LosslessStringConvertible {
        guard let valueData = value.description.data(using: encoding, allowLossyConversion: false) else {
            throw LevelDBError.valueConversionFailed
        }

        try setValue(valueData, forKey: key, options: options)
    }
}

public extension LevelDB where KeyComparator: LevelDBKeyEncoder {
    subscript<Key, Value>(
        key: Key,
        encoding: String.Encoding = .utf8,
        options: ReadOptions = .default
    ) -> Value? where Key: StringProtocol, Value: LosslessStringConvertible {
        do {
            return try value(forKey: key, encoding: encoding, options: options)
        } catch {
            fatalError("Error getting value from DB: \(error))")
        }
    }
}

public extension LevelDB where KeyComparator: LevelDBKeyEncoder {
    func value<Key, Value>(
        forKey key: Key,
        encoding: String.Encoding = .utf8,
        options: ReadOptions = .default
    ) throws -> Value? where Key: StringProtocol, Value: LosslessStringConvertible {
        guard let valueData: Data = try value(forKey: key, options: options) else {
            return nil
        }

        guard let valueString = String(data: valueData, encoding: encoding),
              let value = Value(valueString)
        else {
            throw LevelDBError.valueConversionFailed
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
            throw LevelDBError.valueConversionFailed
        }

        try setValue(valueData, forKey: key, options: options)
    }
}
