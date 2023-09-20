// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

/// A type which converts keys conforming to `StringProtocol` to data objects used in LevelDB instances.
public protocol LevelDBKeyEncoder: AnyObject {
    func encodeKey<Key>(_ key: Key) throws -> Data where Key: StringProtocol
}

/// A type that provides operations for the keys of a LevelDB.
///
/// A key comparator implementation provides an overall order over the keys used in a LevelDB.
///
/// - Important: The implemented methods must be thread-safe any may be invoked concurrently from multiple threads.
public protocol LevelDBKeyComparator: AnyObject {
    /// A name for the comparataor that uniquely identifies it.
    ///
    /// The key comparator name is used to check for comparator mismatches, i.e. if a LevelDB created with one key comparator is accessed using a different comparator.
    ///
    /// - Note: The name of the key comparator should not start with the internally reserved prefix `leveldb.`
    var keyComparatorName: String { get }

    /// Compares two keys.
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the key comparison.
    ///   - rhs: Right hand side of the key comparison.
    ///
    /// - Returns: The result of the key comparison operation.
    func compare(_ lhs: Data, with rhs: Data) -> ComparisonResult

    /// Find the shortest separator between two keys.
    ///
    /// If startKey `<` limitKey, returns a short key in [startKey,limitKey).
    /// This function is used to reduce the space requirements for internal data structures like index blocks.
    ///
    /// - Parameters:
    ///   - startKey: The lower limit key of the range for which the shortest separator should be returned.
    ///   - limitKey: The upper limit key of the range for which the shortest separator should be returned.
    ///
    /// - Returns: Implementations may return `nil` which is the same as returning `startKey` unchanged.
    func findShortestSeparator(startKey: Data, limitKey: Data) -> Data?

    /// Searches for a short successor of a key.
    ///
    /// This function is used to reduce the space requirements for internal data structures like index blocks.
    ///
    /// - Parameter key: The key for which the short successor is to be returned.
    /// 
    /// - Returns: Implementations may return `nil` which is the same as returning the key itself.
    func findShortSuccessor(forKey key: Data) -> Data?
}

public extension LevelDBKeyComparator {
    func findShortestSeparator(startKey: Data, limitKey: Data) -> Data? { nil }
    func findShortSuccessor(forKey key: Data) -> Data? { nil }
}

extension BytewiseKeyComparator: LevelDBKeyComparator & LevelDBKeyEncoder {
    public var keyComparatorName: String { name }

    public func compareKeys(key1: Data, key2: Data) -> ComparisonResult {
        compare(key1, with: key2)
    }

    public func findShortestSeparator(startKey: Data, limitKey: Data) -> Data? {
        findShortestSeparator(startKey, limit: limitKey)
    }

    public func findShortSuccessor(forKey key: Data) -> Data? {
        findShortSuccessor(key)
    }

    public func encodeKey<Key>(_ key: Key) throws -> Data where Key: StringProtocol {
        guard let keyData = key.data(using: .utf8, allowLossyConversion: false) else {
            throw LevelDBError.keyEncodingFailed
        }
        return keyData
    }
}
