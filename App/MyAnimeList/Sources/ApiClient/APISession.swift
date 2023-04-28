//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation
import Dependencies

final actor APISession {
    init(baseURL: URL, urlSessionConfiguration: URLSessionConfiguration) {
        self.baseURL = baseURL
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
    }

    nonisolated let baseURL: URL

    private let urlSession: URLSession
    @Dependency(\.apiLogger) private var apiLogger

    /// - throws: ``APIClientError``.
    @inlinable
    func send<T>(_ request: some Request<T>) async throws -> Response<T> {
        do {
            let urlRequest = try request.makeURLRequest(baseURL: baseURL)
            // Log Request
            apiLogger.logRequest(urlRequest)

            let (data, urlResponse) = try await urlSession.data(for: urlRequest)

            let httpUrlResponse = urlResponse as! HTTPURLResponse
            let response = request.response(from: data, urlResponse: httpUrlResponse)

            // Log Response
            if case let .failure(error) = response.result, case let .decoding(nSError) = error {
                apiLogger.logDecodingError((error: nSError as! DecodingError, urlRequest: urlRequest))
            } else {
                apiLogger.logResponse((object: data, urlResponse: httpUrlResponse, urlRequest: urlRequest))
            }
            return response
        } catch let error as RequestError {
            throw APIClientError.request(error)
        } catch let error as URLError {
            throw APIClientError.urlSession(error)
        } catch {
            throw APIClientError.unknown(error as NSError)
        }
    }
}
