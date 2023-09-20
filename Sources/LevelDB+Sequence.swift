// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

extension LevelDB: Sequence {
    public struct Iterator: IteratorProtocol {
        public typealias Element = (key: Data, value: Data)

        let iterator: CLevelDB.Iterator

        public init(levelDB: LevelDB, readOptions: ReadOptions = .default) {
            iterator = levelDB.cLevelDB.iterator(with: readOptions)
            iterator.seekToFirstEntry()
        }

        public func next() -> Element? {
            guard iterator.isValid else {
                return nil
            }
            let element = (iterator.currentKey(), iterator.currentValue())
            iterator.seekToNextEntry()
            return element
        }
    }

    public func makeIterator(readOptions: ReadOptions) -> Iterator {
        Iterator(levelDB: self, readOptions: readOptions)
    }

    public func makeIterator() -> Iterator {
        Iterator(levelDB: self, readOptions: .default)
    }

    @inlinable public func forEach(readOptions: ReadOptions, _ body: (Iterator.Element) throws -> Void) rethrows {
        let iterator = makeIterator(readOptions: readOptions)
        while let element = iterator.next() {
            try body(element)
        }
    }
}
