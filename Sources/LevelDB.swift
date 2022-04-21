// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

public typealias BytewiseKeyComparator = CLevelDB.BytewiseKeyComparator

public enum LevelDBError: Error {
    case invalidKeyRange
    case keyEncodingFailed
    case valueConversionFailed
}

open class LevelDB<KeyComparator> where KeyComparator: LevelDBKeyComparator {
    public let keyComparator: KeyComparator
    let cLevelDB: CLevelDB

    public init(
        directoryURL url: URL,
        options: Options = .default,
        keyComparator: KeyComparator,
        filterPolicy: FilterPolicy? = nil,
        lruBlockCacheSize: size_t = 0,
        logger: Logger? = nil
    ) throws {
        self.keyComparator = keyComparator

        let keyComparatorFacade = CLevelDBKeyComparatorFacade(keyComparator: keyComparator)
        cLevelDB = try CLevelDB(
            directoryURL: url,
            options: options,
            simpleLogger: logger,
            keyComparator: keyComparatorFacade,
            filterPolicy: filterPolicy,
            lruBlockCacheSize: lruBlockCacheSize
        )
    }

    public func getDBProperty(_ property: LevelDBProperty) -> String? {
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
        return cLevelDB.getApproximateSizes(for: cKeyRanges).map(\.uint64Value)
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
        Snapshot(db: cLevelDB)
    }

    public func forEach(_ body: ((key: Data, value: Data)) throws -> Void, options: ReadOptions = .default) throws {
        for key in cLevelDB.keyEnumerator() {
            let keyData = key as! Data
            let value = try value(forKey: keyData)!
            try body((key: keyData, value: value))
        }
    }
}

public extension LevelDB {
    typealias Options = CLevelDB.Options
    typealias Snapshot = CLevelDB.Snapshot
    typealias Logger = CLevelDB.Logger
    typealias FilterPolicy = CLevelDB.FilterPolicy
    typealias ReadOptions = CLevelDB.ReadOptions
    typealias WriteOptions = CLevelDB.WriteOptions
}

public extension LevelDB {
    convenience init(
        directoryURL url: URL,
        options: Options,
        keyComparator: KeyComparator,
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

public extension LevelDB where KeyComparator == CLevelDB.BytewiseKeyComparator {
    static let version: (major: Int32, minor: Int32) = (CLevelDB.majorVersion, CLevelDB.minorVersion)

    class func destroyDb(at url: URL, options: Options) throws {
        try CLevelDB.destroy(atDirectoryURL: url, options: options)
    }

    class func repairDb(at url: URL, options: Options, logger: Logger? = nil) throws {
        try CLevelDB.repair(atDirectoryURL: url, options: options, simpleLogger: logger)
    }

    class func repairDb(at url: URL, options: Options, logger: @escaping (String) -> Void) throws {
        try CLevelDB.repair(atDirectoryURL: url, options: options, simpleLogger: LevelDBBlockLogger(logger))
    }

    convenience init(
        directoryURL url: URL,
        options: Options = .default,
        filterPolicy: FilterPolicy? = nil,
        lruBlockCacheSize: size_t = 0,
        logger: Logger? = nil
    ) throws {
        try self.init(
            directoryURL: url,
            options: options,
            keyComparator: .init(),
            filterPolicy: filterPolicy,
            lruBlockCacheSize: lruBlockCacheSize,
            logger: logger
        )
    }

    convenience init(
        directoryURL url: URL,
        options: Options,
        filterPolicy: FilterPolicy? = nil,
        lruBlockCacheSize: size_t = 0,
        logger: @escaping (String) -> Void
    ) throws {
        try self.init(
            directoryURL: url,
            options: options,
            keyComparator: .init(),
            filterPolicy: filterPolicy,
            lruBlockCacheSize: lruBlockCacheSize,
            logger: LevelDBBlockLogger(logger)
        )
    }
}
