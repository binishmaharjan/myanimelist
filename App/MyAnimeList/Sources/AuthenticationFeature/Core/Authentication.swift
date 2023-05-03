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
    }

    public enum Action: Equatable{
        case signIn(SignIn.Action)
        case signUp(SignUp.Action)
    }

    public init(){ }

    private let logger = Logger(subsystem: "com.myanimelist", category: "Authentication")

    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .signIn(.delegate(.showSignUp)):
                logger.debug("showSignUp")
                state.phase = .signUp
                return .none

            case .signIn(.delegate(.signInUser(let request))):
                logger.debug("signInUser: username: \(request.username)")
                return .none

            case .signUp(.delegate(.showSignIn)):
                state.phase = .signIn
                logger.debug("showSignIn")
                return .none

            case .signUp(.delegate(.signUpUser(let request))):
                logger.debug("signUpUser")
                return .none
                
            case .signIn:
                return .none

            case .signUp:
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
