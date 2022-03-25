// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB {
    @propertyWrapper
    final class DateWrapper {
        private let key: String
        private weak var _db: LevelDB?
        private var db: LevelDB {
            guard let db = _db else {
                fatalError("Trying to access the levelDB with an invalid reference.")
            }
            return db
        }

        public var wrappedValue: Date? {
            get {
                db[key]
            }
            set {
                db[key] = newValue
            }
        }

        /// - Parameters:
        ///   - key: The key to be used to save the value.
        ///   - db: The levelDB instance used for storing the value. This reference is not getting retained by the PropertyWrapper.
        public init(_ key: String, db: LevelDB) {
            self.key = key
            _db = db
        }
    }
}
