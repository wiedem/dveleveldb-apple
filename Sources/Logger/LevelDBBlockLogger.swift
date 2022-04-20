// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

open class LevelDBBlockLogger: NSObject, CLevelDB.Logger {
    private let logMethod: (String) -> Void

    init(_ logMethod: @escaping (String) -> Void) {
        self.logMethod = logMethod
    }

    public func logMessage(_ message: String) {
        logMethod(message)
    }
}
