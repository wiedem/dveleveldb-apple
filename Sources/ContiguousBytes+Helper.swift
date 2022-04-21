// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

extension ContiguousBytes {
    func withUnsafeData<R>(_ body: (Data) throws -> R) rethrows -> R {
        try withUnsafeBytes { buffer in
            let rawPointer = UnsafeMutableRawPointer(mutating: buffer.baseAddress!)
            let data = Data(bytesNoCopy: rawPointer, count: buffer.count, deallocator: .none)
            return try body(data)
        }
    }
}
