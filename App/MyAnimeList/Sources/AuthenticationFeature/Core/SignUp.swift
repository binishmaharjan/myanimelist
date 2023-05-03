//
//  Created by Maharjan Binish on 2023/05/03.
//

import ComposableArchitecture
import Foundation
import APIClient
import os.log

public struct SignUp: Reducer {
    public struct State: Equatable {
        @BindingState var username: String = ""
        @BindingState var password: String = ""
        var isSignUpButtonDisabled: Bool {
            username.isEmpty || password.isEmpty
        }
    }

    public enum Action: BindableAction, Equatable {
        public enum Delegate: Equatable {
            case showSignIn
            case signUpUser(SignInRequest)
        }
        case signUpButtonTapped
        case signInTextTapped
        case delegate(Delegate)
        case binding(BindingAction<State>)
    }

    private let logger = Logger(subsystem: "com.myanimelist", category: "SignUp")

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .signUpButtonTapped:
                logger.debug("signUpButtonTapped")
                let request = SignInRequest(username: state.username, password: state.password)
                return .send(.delegate(.signUpUser(request)))

            case .signInTextTapped:
                logger.debug("signInTextTapped")
                return .send(.delegate(.showSignIn))

            case .delegate:
                return .none

            case .binding:
                return .none
            }
        }
    }
}
