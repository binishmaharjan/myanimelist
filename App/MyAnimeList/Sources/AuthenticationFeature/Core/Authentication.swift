//
//  Created by Maharjan Binish on 2023/05/03.
//

import APIClient
import Foundation
import ComposableArchitecture
import os.log

public struct Authentication: Reducer {
    public struct State: Equatable {
        public enum Phase: Equatable {
            case signIn
            case signUp
        }

        public init() { }

        var signIn: SignIn.State = SignIn.State()
        var signUp: SignUp.State = SignUp.State()
        var phase: Phase = .signIn
        @BindingState var isLoading = false
    }

    public enum Action: BindableAction, Equatable {
        case signIn(SignIn.Action)
        case signUp(SignUp.Action)
        case toggleLoading(Bool)
        case binding(BindingAction<State>)
    }

    public init(){ }

    @Dependency(\.continuousClock) private var clock

    private let logger = Logger(subsystem: "com.myanimelist", category: "Authentication")

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .signIn(.delegate(.showSignUp)):
                logger.debug("showSignUp")
                state.phase = .signUp
                return .none

            case .signIn(.delegate(.signInUser(let request))):
                logger.debug("signInUser: username: \(request.username)")
                state.isLoading = true

                return .task {
                    try await clock.sleep(for: .seconds(5))
                    return .toggleLoading(false)
                }

            case .signUp(.delegate(.showSignIn)):
                state.phase = .signIn
                logger.debug("showSignIn")
                return .none

            case .signUp(.delegate(.signUpUser(let request))):
                logger.debug("signUpUser")
                state.isLoading = true

                return .task {
                    try await clock.sleep(for: .seconds(5))
                    return .toggleLoading(false)
                }

            case .toggleLoading(let isLoading):
                logger.debug("toggleLoading \(isLoading)")
                state.isLoading = isLoading

                return .none

            case .binding, .signIn, .signUp:
                return .none
            }
        }
        
        Scope(state: \.signIn, action: /Action.signIn) {
            SignIn()
        }

        Scope(state: \.signUp, action: /Action.signUp) {
            SignUp()
        }
    }
}
