// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

public extension CLevelDB.WriteOptions {
    static let `default` = CLevelDB.WriteOptions()

    static func options(syncWrite: Bool) -> CLevelDB.WriteOptions {
        let options = CLevelDB.WriteOptions()
        options.syncWrite = syncWrite
        return options
    }
}
