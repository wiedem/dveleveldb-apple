// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import DVELevelDB_ObjC
import Foundation

open class CodablesLevelDB<Key>: LevelDB<CLevelDB.BytewiseKeyComparator> where Key: CodingKey {
    private let valueCoder: LevelDBValueCoder

    public init(
        directoryURL url: URL,
        options: Options = .default,
        valueCoder: LevelDBValueCoder,
        filterPolicy: FilterPolicy? = nil,
        lruBlockCacheSize: size_t = 0,
        logger: Logger? = nil
    ) throws {
        self.valueCoder = valueCoder

        try super.init(
            directoryURL: url,
            options: options,
            keyComparator: .init(),
            filterPolicy: filterPolicy,
            lruBlockCacheSize: lruBlockCacheSize,
            logger: logger
        )
    }

    public func value<Value>(
        forKey key: Key,
        options: ReadOptions = .default
    ) throws -> Value? where Value: Decodable {
        guard let valueData: Data = try value(forKey: key.stringValue, options: options) else {
            return nil
        }
        return try valueCoder.decode(Value.self, from: valueData)
    }

    public func setValue<Value>(
        _ value: Value,
        forKey key: Key,
        options: WriteOptions = .default
    ) throws where Value: Encodable {
        let valueData = try valueCoder.encode(value)
        try setValue(valueData, forKey: key.stringValue, options: options)
    }

    public func removeValue(forKey key: Key, options: WriteOptions = .default) throws  {
        try removeValue(forKey: key.stringValue, options: options)
    }

    public subscript<Value>(key: Key, options: ReadOptions = .default) -> Value? where Value: Decodable {
       do {
           return try value(forKey: key, options: options)
       } catch {
           fatalError("Error getting value from DB: \(error)")
       }
   }
}
