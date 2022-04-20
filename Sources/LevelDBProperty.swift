// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public enum LevelDBProperty {
    case numFiles(level: UInt64)
    case stats
    case ssTables
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
