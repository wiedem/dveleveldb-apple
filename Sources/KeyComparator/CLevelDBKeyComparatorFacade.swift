// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

public class CLevelDBKeyComparatorFacade: NSObject, CLevelDB.KeyComparator {
    public var name: String { keyComparator.keyComparatorName }

    private let keyComparator: LevelDBKeyComparator

    init(keyComparator: LevelDBKeyComparator) {
        self.keyComparator = keyComparator

        super.init()
    }

    public func compare(_ lhs: Data, with rhs: Data) -> ComparisonResult {
        keyComparator.compare(lhs, with: rhs)
    }

    public func findShortSuccessor(_ key: Data) -> Data? {
        keyComparator.findShortSuccessor(forKey: key)
    }

    public func findShortestSeparator(_ start: Data, limit: Data) -> Data? {
        keyComparator.findShortestSeparator(startKey: start, limitKey: limit)
    }
}
