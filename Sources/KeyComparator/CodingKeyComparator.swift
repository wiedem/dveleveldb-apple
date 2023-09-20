// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

open class CodingKeyComparator<Key>: LevelDBKeyComparator, LevelDBKeyEncoder where Key: CodingKey & Comparable {
    public var keyComparatorName: String { "DVELevelDB.CodingKeyComparator.\(Key.self)" }
    let stringEncoding: String.Encoding = .utf8

    public func encodeKey<StringKey>(_ key: StringKey) throws -> Data where StringKey: StringProtocol {
        guard let keyData = key.data(using: stringEncoding) else {
            throw LevelDBError.keyEncodingFailed
        }
        return keyData
    }

    public func decodeKeyData(_ keyData: Data) throws -> Key {
        guard let keyString = String(data: keyData, encoding: stringEncoding),
              let key = Key(stringValue: keyString)
        else {
            throw LevelDBError.keyEncodingFailed
        }
        return key
    }

    public func compare(_ lhs: Data, with rhs: Data) -> ComparisonResult {
        do {
            let lhsKey = try decodeKeyData(lhs)
            let rhsKey = try decodeKeyData(rhs)

            if lhsKey < rhsKey {
                return .orderedAscending
            } else if lhsKey > rhsKey {
                return .orderedDescending
            }
            return .orderedSame
        } catch {
            fatalError("Error decoding keys for comparison: \(error)")
        }
    }
}
