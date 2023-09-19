// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

public protocol LevelDBDataDecoder: AnyObject {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}

public protocol LevelDBDataEncoder: AnyObject {
    func encode<T>(_ value: T) throws -> Data where T: Encodable
}

extension JSONDecoder: LevelDBDataDecoder {}
extension JSONEncoder: LevelDBDataEncoder {}
extension PropertyListDecoder: LevelDBDataDecoder {}
extension PropertyListEncoder: LevelDBDataEncoder {}

public extension LevelDB {
    func value<Key, Value, Decoder>(
        forKey key: Key,
        decoder: Decoder,
        options: ReadOptions = .default
    ) throws -> Value? where Key: ContiguousBytes, Value: Decodable, Decoder: LevelDBDataDecoder {
        guard let valueData = try value(forKey: key, options: options) else {
            return nil
        }
        return try decoder.decode(Value.self, from: valueData)
    }

    subscript<Key, Value, Decoder>(
        key: Key,
        decoder: Decoder,
        options: ReadOptions = .default
    ) -> Value? where Key: ContiguousBytes, Value: Decodable, Decoder: LevelDBDataDecoder {
        get throws {
            try value(forKey: key, decoder: decoder, options: options)
        }
    }

    func setValue<Value, Key, Encoder>(
        _ value: Value,
        forKey key: Key,
        encoder: Encoder,
        options: WriteOptions = .default
    ) throws where Key: ContiguousBytes, Value: Encodable, Encoder: LevelDBDataEncoder {
        let valueData = try encoder.encode(value)
        try setValue(valueData, forKey: key, options: options)
    }
}

public extension LevelDB where KeyComparator: LevelDBKeyEncoder {
    func value<Key, Value, Decoder>(
        forKey key: Key,
        decoder: Decoder,
        options: ReadOptions = .default
    ) throws -> Value? where Key: StringProtocol, Value: Decodable, Decoder: LevelDBDataDecoder {
        let keyData = try keyComparator.encodeKey(key)
        guard let valueData = try value(forKey: keyData, options: options) else {
            return nil
        }
        return try decoder.decode(Value.self, from: valueData)
    }

    subscript<Key, Value, Decoder>(
        key: Key,
        decoder: Decoder,
        options: ReadOptions = .default
    ) -> Value? where Key: StringProtocol, Value: Decodable, Decoder: LevelDBDataDecoder {
        get throws {
            try value(forKey: key, decoder: decoder, options: options)
        }
    }

    func setValue<Value, Key, Encoder>(
        _ value: Value,
        forKey key: Key,
        encoder: Encoder,
        options: WriteOptions = .default
    ) throws where Key: StringProtocol, Value: Encodable, Encoder: LevelDBDataEncoder {
        let keyData = try keyComparator.encodeKey(key)
        let valueData = try encoder.encode(value)
        try setValue(valueData, forKey: keyData, options: options)
    }
}
