//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation
// {"status":404,"type":"HttpException","message":"Not Found","error":null}

public struct APIError: Error, Hashable, Codable, JSONResponseValue {
    public init(status: Int, code: Code, message: String, error: String? = nil) {
        self.status = status
        self.code = code
        self.message = message
        self.error = error
    }

    public var status: Int
    public var code: Code
    public var message: String
    public var error: String?

    public var isUnauthorized: Bool {
        [.invalidToken, .tokenExpired].contains(code)
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case code = "type"
        case message
        case error
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
    public static let undefined = APIError.Code(rawValue: "undefined")
    /// invalidToken
    public static let invalidToken = APIError.Code(rawValue: "invalidToken")
    /// tokenExpired
    public static let tokenExpired = APIError.Code(rawValue: "tokenExpired")
    /// notFound (actual error)
    public static let notFound = APIError.Code(rawValue: "HttpException")
    /// serverError
    public static let serverError = APIError.Code(rawValue: "serverError")
    /// underMaintenance
    public static let underMaintenance = APIError.Code(rawValue: "underMaintenance")
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

