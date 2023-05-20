//
//  Created by Maharjan Binish on 2023/05/07.
//

import Foundation

//public struct AppErrorState {
//    public init?(
//        _ value: AppError,
//        singleDismissalLabel: String = String(localized: "OK"),
//        dismissalAction: @escaping () -> Void = {},
//        retryAction: @escaping @Sendable () async -> Void
//    ) {
//        // if unauthorized error, then handle separately
//        if case .api(let apiError) = value, apiError.isUnauthorized {
//            return nil
//        }
//
//        self.value = value
//        self.singleDismissalLabel = singleDismissalLabel
//        self.dismissalAction = dismissalAction
//        self.retryAction = {
//            Task {
//                await retryAction()
//            }
//        }
//    }
//
//    public var value: AppError
//    public var singleDismissalLabel: String = String(localized: "OK")
//    public var dismissalAction: () -> Void = {}
//    public var retryAction: () -> Void
//
//    public var isFullScreenError: Bool {
//        if case .api(let apiError) = value, [.serverError, .underMaintenance, .notFound].contains(apiError.code) {
//            return true
//        }
//        return false
//    }
//}

public struct AppErrorState {
    public init?(
        _ value: AppError
    ) {
        self.value = value
    }

    public var value: AppError

    public var isFullScreenError: Bool {
        if case .api(let apiError) = value, [.serverError, .underMaintenance, .notFound].contains(apiError.code) {
            return true
        }
        return false
    }

    public var isMaintenance: Bool {
        if case .api(let apiError) = value, [.underMaintenance].contains(apiError.code) {
            return true
        }
        return false
    }

    public var isServerError: Bool {
        if case .api(let apiError) = value, [.serverError].contains(apiError.code) {
            return true
        }
        return false
    }

    public var isNotFoundError: Bool {
        if case .api(let apiError) = value, [.notFound].contains(apiError.code) {
            return true
        }
        return false
    }
}

extension AppErrorState: Equatable {
    public static func == (lhs: AppErrorState, rhs: AppErrorState) -> Bool {
        lhs.value == rhs.value
    }
}
