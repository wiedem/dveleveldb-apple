// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

public extension LevelDB {
    subscript<Key>(key: Key, options: ReadOptions = .default) -> Data? where Key: ContiguousBytes {
        do {
            return try value(for: key, options: options)
        } catch {
            fatalError("Error getting value from DB: \(error)")
        }
    }

    subscript<Key>(
        key: Key,
        keyEncoding: String.Encoding = .utf8,
        options: ReadOptions = .default
    ) -> Data? where Key: StringProtocol {
        do {
            return try value(for: key, keyEncoding: keyEncoding, options: options)
        } catch {
            fatalError("Error getting value from DB: \(error)")
        }
    }

    subscript<Key>(
        key: Key,
        encoding: String.Encoding = .utf8,
        options: ReadOptions = .default
    ) -> String? where Key: StringProtocol {
        do {
            return try value(for: key, encoding: encoding, options: options)
        } catch {
            fatalError("Error getting value from DB: \(error)")
        }
    }
}
