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
        var isSignInButtonDisabled: Bool {
            username.isEmpty || password.isEmpty
        }
    }

    public enum Action: BindableAction, Equatable {
        public enum Delegate: Equatable {
            case signUp
        }
        case signInButtonTapped
        case delegate(Delegate)
        case binding(BindingAction<State>)
    }

    private let logger = Logger(subsystem: "com.myanimelist", category: "SignIn")

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .signInButtonTapped:
                logger.debug("signInButtonTapped")
                return .send(.delegate(.signUp))

            case .binding(\.$username): // TODO: Remove
                let username = state.username
                logger.debug("\(username)")
                return .none

            case .binding(\.$password):  // TODO: Remove
                let password = state.password
                logger.debug("\(password)")
                return .none

            case .delegate:
                return .none

            case .binding:
                return .none
            }
        }
    }
}
