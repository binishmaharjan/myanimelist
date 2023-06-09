//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation
import Dependencies

public struct APIClient {
    public var fetchAppConfig: @Sendable () async throws -> Response<AppConfig>
    public var fetchAppInfo: @Sendable () async throws -> Response<AppInfo>
    public var signIn: @Sendable (SignInRequest) async throws -> Response<User>
    public var signUp: @Sendable (SignUpRequest) async throws -> Response<User>
}

// MARK: DependencyValues
extension DependencyValues {
    public var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

// MARK: Dependency(Test Value)
extension APIClient: TestDependencyKey {
    public static let testValue = APIClient(
        fetchAppConfig: unimplemented(),
        fetchAppInfo: unimplemented(),
        signIn: unimplemented(),
        signUp: unimplemented()
    )

    /// Preview value for response
    private static let previewHTTPURLResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    /// Preview value for error
    private static let previewErrorResponse = ResponseError.api(
        APIError(status: 404, code: .notFound, message: "Not Found")
    )
    /// Preview value
    public static let previewValue = APIClient(
        fetchAppConfig: {
            Response(result: .success(AppConfig(iOSVersion: "1.0.0")), urlResponse: previewHTTPURLResponse)
        },
        fetchAppInfo: {
            Response(result: .success(AppInfo(termsUpdatedAt: .distantFuture)), urlResponse: previewHTTPURLResponse)
        },
        signIn: { signInRequest in
            Response(
                result: .success(
                    User(
                        id: "id009",
                        username: signInRequest.username,
                        firstName: "First",
                        lastName: "Last")
                ),
                urlResponse: previewHTTPURLResponse
            )
        },
        signUp:  { signUpRequest in
            Response(
                result: .success(
                    User(
                        id: "id009",
                        username: signUpRequest.username,
                        firstName: "First",
                        lastName: "Last")
                ),
                urlResponse: previewHTTPURLResponse
            )
        }
    )
}

private let environmentAPIBaseURLStringKey = "EnvironmentAPIBaseURLString"

private extension Bundle {
    var environmentAPIBaseURL: URL? {
        let urlString = object(forInfoDictionaryKey: environmentAPIBaseURLStringKey) as? String
        let url = urlString.flatMap(URL.init(string:))
        assert(url != nil, "EnvironmentAPIBaseURLString is invalid: \(urlString ?? "nil")")
        return url
    }
}

// MARK: Dependency(Live Value)
extension APIClient: DependencyKey {
#if DEBUG
    public static let liveValue = Self.live(
        baseURL: Bundle.main.environmentAPIBaseURL ?? URL(string: "https://api.jikan.moe/")!,
        urlSessionConfiguration: .default
    )
#else
    public static let liveValue = Self.live(
        // Replace URL
        baseURL: Bundle.main.environmentAPIBaseURL ?? URL(string: "https://api.jikan.moe/")!,
        urlSessionConfiguration: .default
    )
#endif
}


extension APIClient {
    public static func live(baseURL: URL, urlSessionConfiguration: URLSessionConfiguration) -> APIClient {
        let apiSession = APISession(baseURL: baseURL, urlSessionConfiguration: urlSessionConfiguration)
        return APIClient(
            fetchAppConfig: {
//                return Response(result: .failure(previewErrorResponse), urlResponse: previewHTTPURLResponse)
                return Response(result: .success(AppConfig(iOSVersion: "1.0.0")), urlResponse: previewHTTPURLResponse)
            },
            fetchAppInfo: {
                return Response(result: .success(AppInfo(termsUpdatedAt: Date(timeIntervalSince1970: 0))), urlResponse: previewHTTPURLResponse)
            },
            signIn: { signInRequest in
//                Response(
//                    result: .success(
//                        User(
//                            id: "id009",
//                            username: signInRequest.username,
//                            firstName: "First",
//                            lastName: "Last")
//                    ),
//                    urlResponse: previewHTTPURLResponse
//                )
                Response(
                    result: .failure(
                        .api(
                            APIError(
                                status: 404,
                                code: .notFound,
                                message: "Not Found"
                            )
                        )
                    ),
                    urlResponse: previewHTTPURLResponse
                )
            },
            signUp:  { signUpRequest in
                Response(
                    result: .success(
                        User(
                            id: "id009",
                            username: signUpRequest.username,
                            firstName: "First",
                            lastName: "Last")
                    ),
                    urlResponse: previewHTTPURLResponse
                )
            }
        )
    }
}
