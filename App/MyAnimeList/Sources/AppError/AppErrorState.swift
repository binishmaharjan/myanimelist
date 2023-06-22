//
//  Created by Maharjan Binish on 2023/05/07.
//

import Foundation

public struct AppErrorState {
    public init?(
        _ value: AppError
    ) {
        self.value = value
    }

    public var value: AppError

    public var isFullScreenError: Bool {
        return isMaintenance || isServerError
    }

    public var isAlertError: Bool {
        return !isFullScreenError
    }

    public var isUndefined: Bool {
        if case .api(let apiError) = value, [.undefined].contains(apiError.code) {
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

// MARK: Extension
extension AppErrorState: Equatable {
    public static func == (lhs: AppErrorState, rhs: AppErrorState) -> Bool {
        lhs.value == rhs.value
    }
}
