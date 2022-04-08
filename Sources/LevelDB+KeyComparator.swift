// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

typealias LevelDBKeyComparator = CLevelDB.KeyComparator

public extension LevelDB.KeyComparator {
    convenience init(
        name: String,
        comparator: @escaping CLevelDB.KeyComparatorBlock,
        findShortestSeparator: CLevelDB.KeyFindShortestSeparatorBlock? = nil,
        findShortestSuccessor: CLevelDB.KeyFindShortestSuccessorBlock? = nil
    ) {
        self.init(
            __name: name,
            comparator: comparator,
            findShortestSeparator: findShortestSeparator,
            findShortestSuccessor: findShortestSuccessor
        )
    }
}
