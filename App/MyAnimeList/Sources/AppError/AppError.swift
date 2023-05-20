//
//  Created by Maharjan Binish on 2023/05/07.
//

import Foundation
import os.log
import APIClient

private let logger = Logger(subsystem: "com.myanimelist", category: "AppError")

public enum AppError: Error, Hashable, Equatable {
    case api(APIError)
    case network(URLError)
    case general
    case localSystem(NSError)

    public init(error: Error, file: StaticString = #fileID, line: UInt = #line) {
        var dumpedContent = ""
        dump(error, to: &dumpedContent)
        logger.error("[\(file):\(line)]\n\(dumpedContent)")

        switch error {
        case .api(let apiError) as ResponseError:
            self = .api(apiError)

        case .urlSession(let urlError) as APIClientError:
            self = .network(urlError)

        case is ResponseError, is APIClientError:
            self = .general

        default:
            self = .localSystem(error as NSError)
        }
    }
}

// MARK: - LocalizedError
extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .api(let apiError):
            return apiError.errorDescription

        case .network, .general:
            return "Cannot connect to network"

        case .localSystem(let error):
            return error.localizedDescription
        }
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch code {
        case .serverError:
            return "An error has occurred in the server. Please try again later"

        case .undefined:
            return "An unknown error has error"

        case .notFound:
            return "Resource not found. Close the error and check for the problem"

        case .underMaintenance:
            return "App is under maintenance. Please try again later"

        default:
            return nil
        }
    }
}
