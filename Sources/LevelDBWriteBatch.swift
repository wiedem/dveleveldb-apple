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
    func setValue<Value, Key, Encoder>(
        _ value: Value,
        forKey key: Key,
        encoder: Encoder
    ) throws where Key: ContiguousBytes, Value: Encodable, Encoder: LevelDBDataEncoder {
        let valueData = try encoder.encode(value)
        setValue(valueData, forKey: key)
    }
}

public extension LevelDB {
    class WriteBatch: LevelDBWriteBatch {
        private let levelDB: LevelDB
        private let cWriteBatch: CLevelDB.WriteBatch

        public init(levelDB: LevelDB) {
            self.levelDB = levelDB
            cWriteBatch = .init(db: levelDB.cLevelDB)
        }

        public func setValue<Value, Key>(_ value: Value, forKey key: Key) where Value: ContiguousBytes, Key: ContiguousBytes {
            cWriteBatch.setValue(value, forKey: key)
        }

        public func removeValue<Key>(forKey key: Key) where Key: ContiguousBytes {
            cWriteBatch.removeValue(forKey: key)
        }

        public func clear() {
            cWriteBatch.clear()
        }

        public func write(with options: WriteOptions) throws {
            try cWriteBatch.write(with: options)
        }
    }

    @discardableResult
    func writeBatch<Result>(
        writeOptions: WriteOptions = .default,
        _ operations: (WriteBatch) throws -> Result
    ) throws -> Result {
        let writeBatch = WriteBatch(levelDB: self)
        let result = try operations(writeBatch)
        try writeBatch.write(with: writeOptions)
        return result
    }
}

public extension LevelDB.WriteBatch where KeyComparator: LevelDBKeyEncoder {
    func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key
    ) throws where Key: StringProtocol, Value: ContiguousBytes {
        let keyData = try levelDB.keyComparator.encodeKey(key)
        setValue(value, forKey: keyData)
    }

    func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key,
        encoding: String.Encoding = .utf8
    ) throws where Key: StringProtocol, Value: StringProtocol {
        let keyData = try levelDB.keyComparator.encodeKey(key)
        guard let valueData = value.data(using: encoding, allowLossyConversion: false) else {
            throw LevelDBError.valueConversionFailed
        }
        setValue(valueData, forKey: keyData)
    }

    func setValue<Value, Key, Encoder>(
        _ value: Value,
        forKey key: Key,
        encoder: Encoder
    ) throws where Key: StringProtocol, Value: Encodable, Encoder: LevelDBDataEncoder {
        let keyData = try levelDB.keyComparator.encodeKey(key)
        let valueData = try encoder.encode(value)
        setValue(valueData, forKey: keyData)
    }

    func removeValue<Key>(forKey key: Key) throws where Key: StringProtocol {
        let keyData = try levelDB.keyComparator.encodeKey(key)
        removeValue(forKey: keyData)
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
