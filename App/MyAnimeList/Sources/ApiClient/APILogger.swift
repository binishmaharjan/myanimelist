//
//  Created by Maharjan Binish on 2023/04/29.
//

import Dependencies
import Foundation
import os.log

public struct APILogger {
    public typealias LogRequestParameter = URLRequest
    public typealias LogResponseParameter = (object: Any, urlResponse: HTTPURLResponse, urlRequest: URLRequest?)
    public typealias LogDecodingErrorParameter = (error: DecodingError, urlRequest: URLRequest)

    public var logRequest: (URLRequest) -> Void
    public var logResponse: (LogResponseParameter) -> Void
    public var logDecodingError: (LogDecodingErrorParameter) -> Void
}

// MARK: DependencyValues
extension DependencyValues {
    public var apiLogger: APILogger {
        get { self[APILogger.self] }
        set { self[APILogger.self] = newValue }
    }
}

// MARK: Dependency(Test Value)
extension APILogger: TestDependencyKey {
    public static var testValue = APILogger(
        logRequest: unimplemented(),
        logResponse: unimplemented(),
        logDecodingError: unimplemented()
    )
}

// MARK: Dependency(Live Value)
extension APILogger: DependencyKey {
    public static var liveValue = Self.live(logger: Logger(subsystem: "com.myanimelist", category: "APIClient"))

    public static func live(logger: Logger) -> APILogger {
        return APILogger(
            logRequest: { urlRequest in
                let log = """
                ---------------------------------------------
                🚀APIリクエスト
                ```
                - URL: \(urlRequest.url?.description ?? "nil")
                - HTTPMethod: \(urlRequest.httpMethod ?? "nil")
                - HeaderFields:
                \(urlRequest.allHTTPHeaderFields?.prettyLog() ?? "[:]")
                - RequestBody:
                \(JSONSerialization.prettyJSON(of: urlRequest.httpBody))
                ```
                ---------------------------------------------
                """

                logger.debug("\(log)")
            },
            logResponse: { (object, urlResponse, urlRequest) in
                let allHeaderFields = urlResponse.allHeaderFields as? [String: String]
                let log = """
                ---------------------------------------------
                ✅APIレスポンス
                ```
                - StuatsCode: \(urlResponse.statusCode)
                - HeaderFields:
                \(allHeaderFields?.prettyLog() ?? "[:]")
                - ResponseBody:
                \(JSONSerialization.prettyJSON(of: object as? Data))
                ```
                ---------------------------------------------
                """
                logger.debug("\(log)")
            },
            logDecodingError: { (error, urlRequest) in
                let log = """
                ---------------------------------------------
                🤦🏻‍♂️パースエラー
                - URL: \(urlRequest.url?.description ?? "nil")
                \(error)
                ---------------------------------------------
                """
                logger.error("\(log)")
            }
        )
    }
}

extension Dictionary where Key == String, Value == String {
    fileprivate func prettyLog() -> String {
        let lines = keys.sorted().map { key in
            """
                "\(key)": "\(self[key]!)"
            """
        }

        return """
        [
        \(lines.joined(separator: "\n"))
        ]
        """
    }
}

extension JSONSerialization {
    private static let failedText = "failed to decode"

    fileprivate static func prettyJSON(of data: Data?) -> String {
        guard let data = data, let object = try? jsonObject(with: data, options: []) else {
            return failedText
        }

        return prettyJSON(of: object)
    }

    fileprivate static func prettyJSON(of object: Any) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]) else {
            return failedText
        }

        return String(data: data, encoding: .utf8) ?? failedText
    }
}
