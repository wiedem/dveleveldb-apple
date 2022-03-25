// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB.WriteBatch {
    func setValue<Value>(_ value: Value, forKey key: String) where Value: LosslessStringConvertible {
        let newValue: String? = "\(value)"
        setValue(newValue, forKey: key)
    }
}
