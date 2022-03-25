// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB.ReadOptions {
    static func optionsWithSnapshot(_ snapshot: LevelDB.Snapshot) -> LevelDB.ReadOptions {
        let options = LevelDB.ReadOptions()
        options.snapshot = snapshot
        return options
    }
}
