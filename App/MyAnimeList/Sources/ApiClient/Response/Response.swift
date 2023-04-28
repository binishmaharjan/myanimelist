//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation

public struct Response<Value> {
    public init(result: Result<Value, ResponseError>, urlResponse: HTTPURLResponse) {
        self.result = result
        self.urlResponse = urlResponse

        if case .failure(.api(let apiError)) = result, apiError.isUnauthorized {
            NotificationCenter.default.post(name: .unauthorizedNotification, object: self)
        }
    }

    public var result: Result<Value, ResponseError>
    public var urlResponse: HTTPURLResponse

    public var value: Value {
        get throws {
            try result.get()
        }
    }
}

extension Response {
    static func parse(_ data: Data, urlResponse: HTTPURLResponse) -> Self where Value: JSONResponseValue {
        do {
            if 200..<300 ~= urlResponse.statusCode {
                return try Self(result: .success(.decode(from: data)), urlResponse: urlResponse)
            }

            return try Self.init(result: .failure(.api(.decode(from: data))), urlResponse: urlResponse)
        } catch {
            return Self(result: .failure(.decoding(error as NSError)), urlResponse: urlResponse)
        }
    }

    static func parse(_ data: Data, urlResponse: HTTPURLResponse) -> Self where Value == Void {
        if 200..<300 ~= urlResponse.statusCode {
            return Self(result: .success(()), urlResponse: urlResponse)
        }

        do {
            return try Self.init(result: .failure(.api(.decode(from: data))), urlResponse: urlResponse)
        } catch {
            return Self(result: .failure(.decoding(error as NSError)), urlResponse: urlResponse)
        }
    }
}

// MARK: - Notification Name

public extension Notification.Name {
    static let unauthorizedNotification = Notification.Name("ResponseUnauthorizedNotification")
}
