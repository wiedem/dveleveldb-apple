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
        for key: Key,
        decoder: Decoder,
        options: ReadOptions = .default
    ) throws -> Value? where Key: ContiguousBytes, Value: Decodable, Decoder: LevelDBDataDecoder {
        guard let valueData = try value(for: key, options: options) else {
            return nil
        }
        return try decoder.decode(Value.self, from: valueData)
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

public extension LevelDB {
    func value<Key, Value, Decoder>(
        for key: Key,
        keyEncoding: String.Encoding = .utf8,
        decoder: Decoder,
        options: ReadOptions = .default
    ) throws -> Value? where Key: StringProtocol, Value: Decodable, Decoder: LevelDBDataDecoder {
        guard let keyData = key.data(using: keyEncoding, allowLossyConversion: false) else {
            throw CLevelDB.Error(.invalidArgument)
        }
        guard let valueData = try value(for: keyData, options: options) else {
            return nil
        }
        return try decoder.decode(Value.self, from: valueData)
    }

    func setValue<Value, Key, Encoder>(
        _ value: Value,
        forKey key: Key,
        keyEncoding: String.Encoding = .utf8,
        encoder: Encoder,
        options: WriteOptions = .default
    ) throws where Key: StringProtocol, Value: Encodable, Encoder: LevelDBDataEncoder {
        guard let keyData = key.data(using: keyEncoding, allowLossyConversion: false) else {
            throw CLevelDB.Error(.invalidArgument)
        }
        let valueData = try encoder.encode(value)
        try setValue(valueData, forKey: keyData)
    }
}
