//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation

public protocol JSONResponseValue: Decodable {
    static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
}

extension JSONResponseValue {
    public static func decode(from data: Data) throws -> Self {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = Self.keyDecodingStrategy
        decoder.dateDecodingStrategy = Self.dateDecodingStrategy
        return try decoder.decode(self, from: data)
    }
}

// MARK: - Default Implementation
extension JSONResponseValue {
    public static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        .convertFromSnakeCase
    }

    public static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        .api
    }
}
