// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB {
     subscript<Key>(key: Key, options: ReadOptions = .default) -> Data? where Key: ContiguousBytes {
        do {
            return try value(forKey: key, options: options)
        } catch {
            fatalError("Error getting value from DB: \(error)")
        }
    }
}
