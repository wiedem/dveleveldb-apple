// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

open class LevelDB {
    public typealias Options = CLevelDB.Options
    public typealias Logger = CLevelDB.Logger
    public typealias KeyComparator = CLevelDB.KeyComparator
    public typealias FilterPolicy = CLevelDB.FilterPolicy
    public typealias ReadOptions = CLevelDB.ReadOptions
    public typealias WriteOptions = CLevelDB.WriteOptions
    public typealias WriteBatch = CLevelDB.WriteBatch

    public class var majorVersion: Int32 { CLevelDB.majorVersion }
    public class var minorVersion: Int32 { CLevelDB.minorVersion }

    let cLevelDB: CLevelDB

    public init(
        directoryURL url: URL,
        options: Options = .default,
        keyComparator: KeyComparator? = nil,
        filterPolicy: FilterPolicy? = nil,
        lruBlockCacheSize: size_t = 0,
        logger: Logger? = nil
    ) throws {
        cLevelDB = try CLevelDB(
            directoryURL: url,
            options: options,
            simpleLogger: logger,
            keyComparator: keyComparator,
            filterPolicy: filterPolicy,
            lruBlockCacheSize: lruBlockCacheSize
        )
    }

    public func value<Key>(for key: Key, options: ReadOptions = .default) throws -> Data? where Key: ContiguousBytes {
        do {
            return try key.withUnsafeData { keyData in
                try cLevelDB.data(forKey: keyData, options: options)
            }
        } catch CLevelDB.Error.notFound {
            return nil
        }
    }

    public func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key,
        options: WriteOptions = .default
    ) throws where Key: ContiguousBytes, Value: ContiguousBytes {
        try key.withUnsafeData { keyData in
            try value.withUnsafeData { valueData in
                try cLevelDB.setData(valueData, forKey: keyData, options: options)
            }
        }
    }

    public func removeValue<Key>(
        forKey key: Key,
        options: WriteOptions = .default
    ) throws where Key: ContiguousBytes {
        try key.withUnsafeData { keyData in
            try cLevelDB.removeValue(forKey: keyData, options: options)
        }
    }
}

public extension LevelDB {
    convenience init(
        directoryURL url: URL,
        options: Options,
        keyComparator: KeyComparator? = nil,
        filterPolicy: FilterPolicy? = nil,
        lruBlockCacheSize: size_t = 0,
        logger: @escaping (String) -> Void
    ) throws {
        try self.init(
            directoryURL: url,
            options: options,
            keyComparator: keyComparator,
            filterPolicy: filterPolicy,
            lruBlockCacheSize: lruBlockCacheSize,
            logger: LevelDBBlockLogger(logger)
        )
    }

    func value<Key>(
        for key: Key,
        keyEncoding: String.Encoding = .utf8,
        options: ReadOptions = .default
    ) throws -> Data? where Key: StringProtocol {
        guard let keyData = key.data(using: keyEncoding, allowLossyConversion: false) else {
            throw CLevelDB.Error(.invalidArgument)
        }
        return try value(for: keyData)
    }

    func value<Key>(
        for key: Key,
        encoding: String.Encoding = .utf8,
        options: ReadOptions = .default
    ) throws -> String? where Key: StringProtocol {
        guard let keyData = key.data(using: encoding, allowLossyConversion: false) else {
            throw CLevelDB.Error(.invalidArgument)
        }
        guard let valueData = try value(for: keyData, options: options) else {
            return nil
        }
        guard let value = String(data: valueData, encoding: encoding) else {
            throw CLevelDB.Error(.invalidType)
        }
        return value
    }

    func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key,
        keyEncoding: String.Encoding = .utf8,
        options: WriteOptions = .default
    ) throws where Key: StringProtocol, Value: ContiguousBytes {
        guard let keyData = key.data(using: keyEncoding, allowLossyConversion: false) else {
            throw CLevelDB.Error(.invalidArgument)
        }
        try setValue(value, forKey: keyData)
    }

    func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key,
        encoding: String.Encoding = .utf8,
        options: WriteOptions = .default
    ) throws where Key: StringProtocol, Value: StringProtocol {
        guard let keyData = key.data(using: encoding, allowLossyConversion: false),
              let valueData = value.data(using: encoding, allowLossyConversion: false) else {
            throw CLevelDB.Error(.invalidArgument)
        }
        try setValue(valueData, forKey: keyData)
    }

    func removeValue<Key>(
        forKey key: Key,
        keyEncoding: String.Encoding = .utf8,
        options: WriteOptions = .default
    ) throws where Key: StringProtocol {
        guard let keyData = key.data(using: keyEncoding, allowLossyConversion: false) else {
            throw CLevelDB.Error(.invalidArgument)
        }
        try removeValue(forKey: keyData)
    }
}

public extension LevelDB {
    class func destroyDb(at url: URL, options: Options) throws {
        try CLevelDB.destroy(atDirectoryURL: url, options: options)
    }

    class func repairDb(at url: URL, options: Options, logger: Logger? = nil) throws {
        try CLevelDB.repair(atDirectoryURL: url, options: options, simpleLogger: logger)
    }

    class func repairDb(at url: URL, options: Options, logger: @escaping (String) -> Void) throws {
        try CLevelDB.repair(atDirectoryURL: url, options: options, simpleLogger: LevelDBBlockLogger(logger))
    }
}

extension ContiguousBytes {
    func withUnsafeData<R>(_ body: (Data) throws -> R) rethrows -> R {
        try withUnsafeBytes { buffer in
            let rawPointer = UnsafeMutableRawPointer(mutating:  buffer.baseAddress!)
            let data = Data(bytesNoCopy: rawPointer, count: buffer.count, deallocator: .none)
            return try body(data)
        }
    }
}
