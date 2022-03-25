// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB.WriteBatch {
    func setValue(_ value: Date?, forKey key: String) {
        guard let newValue = value else {
            removeValue(forKey: key)
            return
        }
        let newStringValue = LevelDB.dateFormatter.string(from: newValue)
        setValue(newStringValue, forKey: key)
    }
}
