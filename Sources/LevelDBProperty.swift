// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

/// A LevelDB state property.
public enum LevelDBProperty {
    /// The number of files for the DB at the specified level.
    case numFiles(level: UInt64)
    /// The statistics about the internal operations of the DB.
    case stats
    /// A description of all sstables that make up the DB contents.
    case ssTables
    /// The current approximate memory usage of the DB in bytes.
    case approximateMemoryUsage
}

public extension LevelDBProperty {
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
