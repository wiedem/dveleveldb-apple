// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

open class LevelDB {
    public enum DBProperty {
        case numFiles(level: UInt64)
        case stats
        case ssTables
        case approximateMemoryUsage
    }

    public typealias Options = CLevelDB.Options
    public typealias Snapshot = CLevelDB.Snapshot
    public typealias Logger = CLevelDB.Logger
    public typealias KeyComparator = CLevelDB.BlockKeyComparator
    public typealias FilterPolicy = CLevelDB.FilterPolicy
    public typealias ReadOptions = CLevelDB.ReadOptions
    public typealias WriteOptions = CLevelDB.WriteOptions
    public typealias WriteBatch = CLevelDB.WriteBatch
    public typealias Error = CLevelDB.Error

    public static let version: (major: Int32, minor: Int32) = (CLevelDB.majorVersion, CLevelDB.minorVersion)

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

    public func getDBProperty(_ property: DBProperty) -> String? {
        return cLevelDB.dbProperty(forKey: property.key)
    }

    public func value<Key>(forKey key: Key, options: ReadOptions = .default) throws -> Data? where Key: ContiguousBytes {
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

    public func getApproximateSizes<Key>(
        forKeyRanges keyRanges: [(startKey: Key, limitKey: Key)]
    ) -> [UInt64] where Key: ContiguousBytes {
        let cKeyRanges = keyRanges.map { keyRange in
            keyRange.startKey.withUnsafeData { startKeyData in
                keyRange.limitKey.withUnsafeData { limitKeyData in
                    CLevelDB.KeyRange(startKey: startKeyData, limitKey: limitKeyData)
                }
            }
        }
        return cLevelDB.getApproximateSizes(for: cKeyRanges).map { $0.uint64Value }
    }

    public func compact() {
        cLevelDB.compact(withStartKey: nil, endKey: nil)
    }

    public func compact<Key>(startKey: Key) where Key: ContiguousBytes {
        startKey.withUnsafeData { startKeyData in
            cLevelDB.compact(withStartKey: startKeyData, endKey: nil)
        }
    }

    public func compact<Key>(endKey: Key) where Key: ContiguousBytes {
        endKey.withUnsafeData { endKeyData in
            cLevelDB.compact(withStartKey: nil, endKey: endKeyData)
        }
    }

    public func compact<Key>(startKey: Key, endKey: Key) where Key: ContiguousBytes {
        startKey.withUnsafeData { startKeyData in
            endKey.withUnsafeData { endKeyData in
                cLevelDB.compact(withStartKey: startKeyData, endKey: endKeyData)
            }
        }
    }

    public func compact<Key>(keyRange: ClosedRange<Key>) where Key: ContiguousBytes {
        guard keyRange.isEmpty == false else {
            return
        }

        keyRange.lowerBound.withUnsafeData { startKeyData in
            keyRange.upperBound.withUnsafeData { endKeyData in
                cLevelDB.compact(withStartKey: startKeyData, endKey: endKeyData)
            }
        }
    }

    public func createSnapshot() -> Snapshot {
        .init(db: cLevelDB)
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

public extension LevelDB.DBProperty {
    static let keyPrefix = "leveldb"

    var key: String {
        let key: String
        switch self {
        case let .numFiles(level):
            key = "num-files-at-level\(level)"
        case .stats:
            key = "stats"
        case .ssTables:
            key = "sstables"
        case .approximateMemoryUsage:
            key = "approximate-memory-usage"
        }
        return "\(Self.keyPrefix).\(key)"
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
