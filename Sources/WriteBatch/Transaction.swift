// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public extension LevelDB {
    @discardableResult
    func transaction<Result>(writeOptions: WriteOptions = .init(), _ operations: (WriteBatch) -> Result) throws -> Result {
        let writeBatch = WriteBatch(db: self)
        let result = operations(writeBatch)
        try writeBatch.write(with: writeOptions)
        return result
    }
}
