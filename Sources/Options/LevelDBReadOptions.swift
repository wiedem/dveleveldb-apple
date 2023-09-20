// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

public extension CLevelDB.ReadOptions {
    static let `default` = CLevelDB.ReadOptions()

    static func options(verifyChecksums: Bool, fillCache: Bool, snapshot: CLevelDB.Snapshot? = nil) -> CLevelDB.ReadOptions {
        let options = CLevelDB.ReadOptions()
        options.verifyChecksums = verifyChecksums
        options.fillCache = fillCache
        options.snapshot = snapshot
        return options
    }

    static func usingSnapshot(_ snapshot: CLevelDB.Snapshot) -> CLevelDB.ReadOptions {
        let options = CLevelDB.ReadOptions()
        options.snapshot = snapshot
        return options
    }
}
