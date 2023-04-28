//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation

public protocol RequestBody {
    var contentType: String { get }

    /// - throws: `Error`
    func encoded() throws -> Data
}

/// MARK: - Confirmations
struct JSONRequestBody: RequestBody {
    let json: Any
    let contentType = "application/json"

    init(json: Any) {
        self.json = json
    }

    init(dictionary: () -> [String: Any]) {
        self.init(json: dictionary())
    }

    init(array: () -> [[String: Any]]) {
        self.init(json: array())
    }

    func encoded() throws -> Data {
        try JSONSerialization.data(withJSONObject: json)
    }
}

// MARK: -
struct EncodableJSONRequestBody<Value: JSONEncodable>: RequestBody {
    var value: Value
    let contentType = "application/json"

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = value.keyEncodingStrategy
        encoder.dateEncodingStrategy = value.dateEncodingStrategy
        return try encoder.encode(value)
    }
}

public protocol JSONEncodable: Encodable {
    var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy { get }
    var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }
}

extension JSONEncodable {
    var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy { .convertToSnakeCase }
    var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { .api }
}
