// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

enum TestError: Error {
    case noFailure
    case failure
}

func createTemporaryDirectory(fileManager: FileManager = .default) -> URL {
    let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    return try! fileManager.url(
        for: .itemReplacementDirectory,
        in: .userDomainMask,
        appropriateFor: url,
        create: true
    )
}
