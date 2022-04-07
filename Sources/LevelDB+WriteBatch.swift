// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

public protocol LevelDBWriteBatch: AnyObject {
    func setValue<Value, Key>(_ value: Value, forKey key: Key) where Key: ContiguousBytes, Value: ContiguousBytes
    func removeValue<Key>(forKey key: Key) where Key: ContiguousBytes
    func clear()
}

public extension LevelDBWriteBatch {
    func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key,
        keyEncoding: String.Encoding = .utf8
    ) throws where Key: StringProtocol, Value: ContiguousBytes {
        guard let keyData = key.data(using: keyEncoding, allowLossyConversion: false) else {
            throw LevelDB.Error(.invalidArgument)
        }
        setValue(value, forKey: keyData)
    }

    func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key,
        encoding: String.Encoding = .utf8
    ) throws where Key: StringProtocol, Value: StringProtocol {
        guard let keyData = key.data(using: encoding, allowLossyConversion: false),
              let valueData = value.data(using: encoding, allowLossyConversion: false) else {
            throw LevelDB.Error(.invalidArgument)
        }
        setValue(valueData, forKey: keyData)
    }

    func removeValue<Key>(forKey key: Key, keyEncoding: String.Encoding = .utf8) throws where Key: StringProtocol {
        guard let keyData = key.data(using: keyEncoding, allowLossyConversion: false) else {
            throw LevelDB.Error(.invalidArgument)
        }
        removeValue(forKey: keyData)
    }
}

public extension LevelDBWriteBatch {
    func setValue<Value, Key, Encoder>(
        _ value: Value,
        forKey key: Key,
        encoder: Encoder
    ) throws where Key: ContiguousBytes, Value: Encodable, Encoder: LevelDBDataEncoder {
        let valueData = try encoder.encode(value)
        setValue(valueData, forKey: key)
    }

    func setValue<Value, Key, Encoder>(
        _ value: Value,
        forKey key: Key,
        keyEncoding: String.Encoding = .utf8,
        encoder: Encoder
    ) throws where Key: StringProtocol, Value: Encodable, Encoder: LevelDBDataEncoder {
        guard let keyData = key.data(using: keyEncoding, allowLossyConversion: false) else {
            throw LevelDB.Error(.invalidArgument)
        }
        let valueData = try encoder.encode(value)
        setValue(valueData, forKey: keyData)
    }
}

public extension LevelDB {
    @discardableResult
    func writeBatch<Result>(
        writeOptions: WriteOptions = .default,
        _ operations: (LevelDBWriteBatch) throws -> Result
    ) throws -> Result {
        let writeBatch = WriteBatch(db: cLevelDB)
        let result = try operations(writeBatch)
        try writeBatch.write(with: writeOptions)
        return result
    }
}

extension CLevelDB.WriteBatch: LevelDBWriteBatch {
    public func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key
    ) where Key: ContiguousBytes, Value: ContiguousBytes {
        key.withUnsafeData { keyData in
            value.withUnsafeData { valueData in
                setData(valueData, forKey: keyData)
            }
        }
    }

    public func removeValue<Key>(forKey key: Key) where Key: ContiguousBytes {
        key.withUnsafeData { keyData in
            removeValue(forKey: keyData)
        }
    }
}
