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

/// A LevelDB instance for fast key-value storage.
///
/// A LevelDB instance is a key-value store with arbitrary keys and values.
/// The ``KeyComparator`` type defines how keys are handled in the database.
///
/// - Note: There's no explicit method to close a database instance, the database will be automatically closed when the instance is deinitialized.
open class LevelDB<KeyComparator> where KeyComparator: LevelDBKeyComparator {
    /// The version of the LevelDB engine.
    public static var version: (major: Int32, minor: Int32) {
        (CLevelDB.majorVersion, CLevelDB.minorVersion)
    }

    /// The directory URL with which the LevelDB instance was initialized.
    public var directoryURL: URL {
        cLevelDB.directoryURL
    }

    /// The key comparator, which is used for key-based operations in the LevelDB
    public let keyComparator: KeyComparator

    let cLevelDB: CLevelDB

    /// Creates a new LevelDB instance.
    ///
    /// If a database already exists at the specified URL, it will be opened.
    /// Otherwise the ``Options.createDBIfMissing`` defines if a new database will be automatically created.
    /// If the value is `false` and the database doesn't exist, an error will be thrown.
    ///
    /// - Parameters:
    ///   - url: File URL of the database.
    ///   - options: Options for opening the database.
    ///   - keyComparator: The key comparator used for handling key related operations.
    ///   - filterPolicy: A filter policy used to reduce disk reads.
    ///   - lruBlockCacheSize: The size of the LRU block cache used by the database instance.
    ///   - logger: A logger instance for log operations.
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

    /// Returs a state property of the LevelDB implementation.
    ///
    /// This method makes state informations about the underlying LevelDB implementations available.
    ///
    /// - Parameter property: The property to get.
    /// - Returns: The value of the property if available.
    public func getDBProperty(_ property: LevelDBProperty) -> String? {
        cLevelDB.dbProperty(forKey: property.key)
    }

    /// Accesses the value associated with the given key.
    ///
    /// - Parameters:
    ///   - key: The key to find in the LevelDB.
    ///   - options: The LevelDB read options for the operation.
    ///
    /// - Returns: Returns the value of the key if `key` is in the DB; otherwise, `nil`.
    public func value<Key>(forKey key: Key, options: ReadOptions = .default) throws -> Data? where Key: ContiguousBytes {
        do {
            return try key.withUnsafeData { keyData in
                try cLevelDB.data(forKey: keyData, options: options)
            }
        } catch CLevelDB.Error.notFound {
            return nil
        }
    }

    /// Sets the value stored in the DB for the given key, or adds a new key-value pair if the key does not exist.
    ///
    /// - Parameters:
    ///   - value: The new value to add to the DB.
    ///   - key: The key to associate with `value`. If `key` already exists in the DB, `value` replaces the existing associated value.
    ///   - options: The LevelDB write options for the operation.
    public func setValue<Value, Key>(
        _ value: Value,
        forKey key: Key,
        options: WriteOptions = .default
    ) throws where Key: ContiguousBytes, Value: ContiguousBytes {
        try withUnsafeData(key, value) { keyData, valueData in
            try cLevelDB.setData(valueData, forKey: keyData, options: options)
        }
    }

    /// Removes a value stored in the DB for a specific key.
    ///
    /// - Parameters:
    ///   - key: The key of the value to be removed from the DB.
    ///   - options: The LevelDB write options for the operation.
    public func removeValue<Key>(
        forKey key: Key,
        options: WriteOptions = .default
    ) throws where Key: ContiguousBytes {
        try key.withUnsafeData { keyData in
            try cLevelDB.removeValue(forKey: keyData, options: options)
        }
    }

    /// Gets the approximate sizes for the given key ranges.
    ///
    /// The results may not include the sizes of recently written data.
    ///
    /// - Parameter keyRanges: The key ranges for which the approximate sizes should be returned.
    ///
    /// - Returns:
    /// An array with size values for the specified key ranges.
    /// Note that the returned sizes measure file system space usage.
    /// In case the DB uses data compression, the values returned are the sizes of the compressed user data.
    public func getApproximateSizes<Key>(
        forKeyRanges keyRanges: [(startKey: Key, limitKey: Key)]
    ) -> [UInt64] where Key: ContiguousBytes {
        let cKeyRanges = keyRanges.map { keyRange in
            withUnsafeData(keyRange.startKey, keyRange.limitKey) { startKeyData, limitKeyData in
                CLevelDB.KeyRange(startKey: Data(startKeyData), limitKey: Data(limitKeyData))
            }
        }
        return cLevelDB.getApproximateSizes(for: cKeyRanges).map(\.uint64Value)
    }

    /// Compact the underlying storage of the LevelDB.
    ///
    /// Deleted and overwritten versions are discarded and the data is rearranged to reduce the cost of operations needed to access the data.
    /// This operation should typically only be invoked by users who understand the underlying implementation.
    public func compact() {
        cLevelDB.compact(withStartKey: nil, endKey: nil)
    }

    /// Compact the underlying storage of the LevelDB starting at a given key.
    ///
    /// Deleted and overwritten versions are discarded and the data is rearranged to reduce the cost of operations needed to access the data.
    /// This operation should typically only be invoked by users who understand the underlying implementation.
    ///
    /// - Parameter startKey: The key defining the start of the operation. The key itself is included.
    public func compact<Key>(startKey: Key) where Key: ContiguousBytes {
        startKey.withUnsafeData { startKeyData in
            cLevelDB.compact(withStartKey: startKeyData, endKey: nil)
        }
    }

    /// Compact the underlying storage of the LevelDB up to a given key.
    ///
    /// Deleted and overwritten versions are discarded and the data is rearranged to reduce the cost of operations needed to access the data.
    /// This operation should typically only be invoked by users who understand the underlying implementation.
    ///
    /// - Parameter endKey: The key defining the end of the operation. The key itself is included.
    public func compact<Key>(endKey: Key) where Key: ContiguousBytes {
        endKey.withUnsafeData { endKeyData in
            cLevelDB.compact(withStartKey: nil, endKey: endKeyData)
        }
    }

    /// Compact the underlying storage of the LevelDB for a given key range.
    ///
    /// Deleted and overwritten versions are discarded and the data is rearranged to reduce the cost of operations needed to access the data.
    /// This operation should typically only be invoked by users who understand the underlying implementation.
    ///
    /// - Parameters:
    ///   - startKey: The key defining the start of the operation. The key itself is included.
    ///   - endKey: The key defining the end of the operation. The key itself is included.
    public func compact<Key>(startKey: Key, endKey: Key) where Key: ContiguousBytes {
        withUnsafeData(startKey, endKey) { startKeyData, endKeyData in
            cLevelDB.compact(withStartKey: startKeyData, endKey: endKeyData)
        }
    }

    /// Compact the underlying storage of the LevelDB for a given key range.
    ///
    /// Deleted and overwritten versions are discarded and the data is rearranged to reduce the cost of operations needed to access the data.
    /// This operation should typically only be invoked by users who understand the underlying implementation.
    ///
    /// - Parameter keyRange: The closed key range for the operation.
    public func compact<Key>(keyRange: ClosedRange<Key>) where Key: ContiguousBytes {
        guard keyRange.isEmpty == false else {
            return
        }

        withUnsafeData(keyRange.lowerBound, keyRange.upperBound) { startKeyData, endKeyData in
            cLevelDB.compact(withStartKey: startKeyData, endKey: endKeyData)
        }
    }

    public func createSnapshot() -> Snapshot {
        Snapshot(db: cLevelDB)
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
    /// The version of the LevelDB engine.
    static var version: (major: Int32, minor: Int32) {
        (CLevelDB.majorVersion, CLevelDB.minorVersion)
    }

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
