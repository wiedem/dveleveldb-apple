// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC

public typealias LevelDB = CLevelDB

public extension LevelDB {
    class func destroyDb(at url: URL, options: Options) throws {
        try __destroy(atDirectoryURL: url, options: options)
    }

    class func repairDb(at url: URL, options: Options) throws {
        try __repair(atDirectoryURL: url, options: options)
    }

    convenience init(
        directoryURL url: URL,
        options: Options,
        logger: Logger? = VoidLogger(),
        keyComparator: KeyComparator? = nil,
        filterPolicy: FilterPolicy? = nil,
        lruBlockCacheSize: size_t = 0
    ) throws {
        try self.init(
            __directoryURL: url,
            options: options,
            simpleLogger: logger,
            keyComparator: keyComparator,
            filterPolicy: filterPolicy,
            lruBlockCacheSize: lruBlockCacheSize
        )
    }

    convenience init(
        directoryURL url: URL,
        options: Options,
        formatLogger: FormatLogger,
        keyComparator: KeyComparator? = nil,
        filterPolicy: FilterPolicy? = nil,
        lruBlockCacheSize: size_t = 0
    ) throws {
        try self.init(
            __directoryURL: url,
            options: options,
            formatLogger: formatLogger,
            keyComparator: keyComparator,
            filterPolicy: filterPolicy,
            lruBlockCacheSize: lruBlockCacheSize
        )
    }

    func value(forKey key: String) throws -> String? {
        do {
            return try __value(forKey: key)
        } catch LevelDB.Error.notFound {
            return nil
        } catch {
            throw error
        }
    }

    func value(forKey key: String, options: ReadOptions) throws -> String? {
        do {
            return try __value(forKey: key, options: options)
        } catch LevelDB.Error.notFound {
            return nil
        } catch {
            throw error
        }
    }
}
