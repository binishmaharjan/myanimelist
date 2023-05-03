//
//  Created by Maharjan Binish on 2023/05/02.
//

import ComposableArchitecture
import Foundation
import os.log

public struct SignIn: Reducer {
    public struct State: Equatable {
        @BindingState var username: String = ""
        @BindingState var password: String = ""
    }

    public enum Action: BindableAction, Equatable {
        case signInButtonTapped
        case binding(BindingAction<State>)
    }

    private let logger = Logger(subsystem: "com.myanimelist", category: "SignIn")

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .signInButtonTapped:
                logger.debug("signInButtonTapped")
                return .none

            case .binding(\.$username): // TODO: Remove
                let username = state.username
                logger.debug("\(username)")
                return .none

            case .binding(\.$password):  // TODO: Remove
                let password = state.password
                logger.debug("\(password)")
                return .none

            case .binding:
                return .none
            }
        }
    }
}
