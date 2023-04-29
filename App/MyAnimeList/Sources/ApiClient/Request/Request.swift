//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation

public enum HTTPMethod: String {
    case get, post, put, delete
}

public enum APIVersion: String {
    case v1
    case v2
    case v3
    case v4

    public var path: String { "/\(rawValue)" }
}

public protocol Request<Success> {
    associatedtype Success

    var method: HTTPMethod { get }
    var apiVersion: APIVersion { get }
    var path: String { get }
    var headerFields: [String: String] { get }
    var queries: [String: String] { get }
    var queryParameters: QueryParameters? { get }
    var body: RequestBody? { get }

    func response(from data: Data, urlResponse: HTTPURLResponse) -> Response<Success>
}

extension Request {
    public var apiVersion: APIVersion { .v4 }
    public var headerFields: [String: String] { [:] }
    public var queries: [String: String] { [:] }
    public var queryParameters: QueryParameters? {
        if queries.isEmpty {
            return nil
        }
        return QueryParameters(queries)
    }
    public var body: RequestBody? { nil }
}

extension Request {
    public func response(from data: Data, urlResponse: HTTPURLResponse) -> Response<Success> where Success: JSONResponseValue {
        Response.parse(data, urlResponse: urlResponse)
    }

    public func response(from data: Data, urlResponse: HTTPURLResponse) -> Response<Success> where Success == Void {
        Response.parse(data, urlResponse: urlResponse)
    }
}

// MARK: - Authorizable Request
public protocol AuthorizableRequest<Success>: Request {
    var accessToken: String { get }
}

extension AuthorizableRequest {
    public var headerFields: [String : String] {
        ["Authorization": "Bearer \(accessToken)"]
    }
}

// MARK: - URLRequest Factory

extension Request {
    @usableFromInline
    func makeURLRequest(baseURL: URL) throws -> URLRequest {
        let baseURL = baseURL.appendingPathComponent(apiVersion.path)
        // 後からURLComponents.pathに割り当てると、baseURLに含まれるパスが上書きされてしまうため、代わりにあらかじめpathも結合しておく。
        let url = path.isEmpty ? baseURL : baseURL.appendingPathComponent(path)
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw RequestError.invalidEndpoint(url)
        }

        // `percentEncodedQueryItems`に空配列を設定するとURLの末尾に"?"のみ挿入されてしまうため、`queries.isEmpty == true`の場合は`nil`の状態をキープさせる。
        if let queryParameters, !queryParameters.isEmpty {
            urlComponents.percentEncodedQueryItems = queryParameters.percentEncodedURLQueryItems
        }

        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = method.rawValue.uppercased()
        headerFields.forEach {
            urlRequest.setValue($1, forHTTPHeaderField: $0)
        }

        guard let body else {
            return urlRequest
        }

        do {
            urlRequest.httpBody = try body.encoded()
            urlRequest.setValue(body.contentType, forHTTPHeaderField: "Content-Type")
        } catch {
            throw RequestError.requestBodyEncodingFailed(error as NSError)
        }

        return urlRequest
    }
}
