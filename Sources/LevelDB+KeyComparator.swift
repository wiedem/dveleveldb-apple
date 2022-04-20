// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

typealias LevelDBKeyComparator = CLevelDB.KeyComparator

public extension LevelDBKeyComparator {
    var stringEncoding: String.Encoding? {
        guard __stringEncoding != 0 else { return nil }
        return String.Encoding(rawValue: __stringEncoding)
    }
}

public extension LevelDB.KeyComparator {
    convenience init(
        name: String,
        stringEncoding: String.Encoding,
        comparator: @escaping CLevelDB.KeyComparatorBlock,
        findShortestSeparator: CLevelDB.KeyFindShortestSeparatorBlock? = nil,
        findShortestSuccessor: CLevelDB.KeyFindShortestSuccessorBlock? = nil
    ) {
        self.init(
            __name: name,
            stringEncoding: stringEncoding.rawValue,
            comparator: comparator,
            findShortestSeparator: findShortestSeparator,
            findShortestSuccessor: findShortestSuccessor
        )
    }
}
