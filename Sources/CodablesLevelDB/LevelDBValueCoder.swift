// Copyright (c) diva-e NEXT GmbH. All rights reserved.
// Licensed under the MIT License.

import Foundation

public protocol LevelDBValueCoder: AnyObject {
    func encode<T>(_ value: T) throws -> Data where T: Encodable
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}

open class LevelDBJSONValueCoder: LevelDBValueCoder {
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    public init(jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    public func encode<T>(_ value: T) throws -> Data where T: Encodable {
        try jsonEncoder.encode(value)
    }

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        try jsonDecoder.decode(type, from: data)
    }
}
