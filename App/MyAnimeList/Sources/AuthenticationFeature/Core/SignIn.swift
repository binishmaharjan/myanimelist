//
//  Created by Maharjan Binish on 2023/05/02.
//

import APIClient
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
            case showSignUp
            case signInUser(SignInRequest)
        }
        case onAppear
        case signInButtonTapped
        case signUpTextTapped
        case delegate(Delegate)
        case binding(BindingAction<State>)
    }

    private let logger = Logger(subsystem: "com.myanimelist", category: "SignIn")

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                logger.debug("onAppear")
                state.username = ""
                state.password = ""
                return .none

            case .signInButtonTapped:
                logger.debug("signInButtonTapped")
                let request = SignInRequest(username: state.username, password: state.password)
                return .send(.delegate(.signInUser(request)))

            case .signUpTextTapped:
                logger.debug("signUpTextTapped")
                return .send(.delegate(.showSignUp))

            case .delegate:
                return .none

            case .binding:
                return .none
            }
        }
    }
}
