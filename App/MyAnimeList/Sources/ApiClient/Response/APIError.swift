//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation

public struct APIError: Error, Hashable, Codable, JSONResponseValue {
    public init(code: Code, contents: [Content]) {
        self.code = code
        self.contents = contents
    }

    public struct Content: Hashable, Codable {
        public init(name: String? = nil, message: String) {
            self.name = name
            self.message = message
        }

        public var name: String?
        public var message: String
    }

    public var code: Code
    public var contents: [Content]

    public var isUnauthorized: Bool {
        [.invalidToken, .tokenExpired].contains(code)
    }

    private enum CodingKeys: String, CodingKey {
        case code = "error_code"
        case contents = "errors"
    }

    public static let keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.useDefaultKeys
}


extension APIError {
    public struct Code: RawRepresentable, Hashable {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension APIError.Code {
    /// undefined
    public static let undefined = Self(rawValue: "undefined")
    /// invalidToken
    public static let invalidToken = Self(rawValue: "invalidToken")
    /// tokenExpired
    public static let tokenExpired = Self(rawValue: "tokenExpired")
    /// notFound
    public static let notFound = Self(rawValue: "notFound")
    /// serverError
    public static let serverError = Self(rawValue: "serverError")
    /// underMaintenance
    public static let underMaintenance = Self(rawValue: "underMaintenance")
}

extension APIError.Code: Codable {
    public init(from decoder: Decoder) throws {
        self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

