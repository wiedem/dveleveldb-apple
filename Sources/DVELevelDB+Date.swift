// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB {
    internal static let dateFormatter = ISO8601DateFormatter()

    subscript(key: String) -> Date? {
        get {
            do {
                guard let stringValue = try value(forKey: key) else {
                    return nil
                }
                guard let date = Self.dateFormatter.date(from: stringValue) else {
                    throw LevelDB.Error(.invalidType)
                }
                return date
            } catch {
                fatalError("Error getting value from DB: \(error)")
            }
        }
        set {
            do {
                guard let newValue = newValue else {
                    try removeValue(forKey: key)
                    return
                }
                let newStringValue = Self.dateFormatter.string(from: newValue)
                try setValue(newStringValue, forKey: key)
            } catch {
                fatalError("Error setting value in DB: \(error)")
            }
        }
    }

    func date(forKey key: String) throws -> Date? {
        do {
            guard let stringValue = try value(forKey: key) else {
                return nil
            }
            guard let date = Self.dateFormatter.date(from: stringValue) else {
                throw LevelDB.Error(.invalidType)
            }
            return date
        } catch {
            throw error
        }
    }

    func date(forKey key: String, options: ReadOptions) throws -> Date? {
        do {
            guard let stringValue = try value(forKey: key, options: options) else {
                return nil
            }
            guard let date = Self.dateFormatter.date(from: stringValue) else {
                throw LevelDB.Error(.invalidType)
            }
            return date
        } catch LevelDB.Error.notFound {
            return nil
        } catch {
            throw error
        }
    }
}
