// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB.Options {
    static let `default`: LevelDB.Options = {
        let options = LevelDB.Options()
        options.createDBIfMissing = true
        options.compression = .snappy
        return options
    }()
}
