// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

func withUnsafeData<R>(
    _ bytes1: ContiguousBytes,
    _ bytes2: ContiguousBytes,
    body: (Data, Data) throws -> R
) rethrows -> R {
    try bytes1.withUnsafeData { data1 in
        try bytes2.withUnsafeData { data2 in
            try body(data1, data2)
        }
    }
}

extension ContiguousBytes {
    func withUnsafeData<R>(_ body: (Data) throws -> R) rethrows -> R {
        try withUnsafeBytes { buffer in
            let rawPointer = UnsafeMutableRawPointer(mutating: buffer.baseAddress!)
            let data = Data(bytesNoCopy: rawPointer, count: buffer.count, deallocator: .none)
            return try body(data)
        }
    }
}
