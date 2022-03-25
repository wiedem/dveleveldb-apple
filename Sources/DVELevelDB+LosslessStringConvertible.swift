// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB {
    subscript<Value>(key: String) -> Value? where Value: LosslessStringConvertible {
        get {
            do {
                return try value(forKey: key)
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
                try setValue(newValue, forKey: key)
            } catch {
                fatalError("Error setting value in DB: \(error)")
            }
        }
    }

    func setValue<Value>(_ value: Value, forKey key: String, options: WriteOptions = .init()) throws where Value: LosslessStringConvertible {
        let newValue: String? = "\(value)"
        try setValue(newValue, forKey: key)
    }

    func value<Value>(forKey key: String) throws -> Value? where Value: LosslessStringConvertible {
        do {
            guard let stringValue = try value(forKey: key) else {
                return nil
            }
            guard let value = Value(stringValue) else {
                throw LevelDB.Error(.invalidType)
            }
            return value
        } catch {
            throw error
        }
    }

    func value<Value>(forKey key: String, options: ReadOptions) throws -> Value? where Value: LosslessStringConvertible {
        do {
            guard let stringValue = try value(forKey: key, options: options) else {
                return nil
            }
            guard let value = Value(stringValue) else {
                throw LevelDB.Error(.invalidType)
            }
            return value
        } catch {
            throw error
        }
    }
}
