//
//  Created by Maharjan Binish on 2023/05/03.
//

import APIClient
import Foundation
import ComposableArchitecture
import os.log

public struct Authentication: Reducer {
    public struct State: Equatable {
        public init() { }
        var signIn: SignIn.State = SignIn.State()
    }

    public enum Action: Equatable{
        case signIn(SignIn.Action)
    }

    public init(){ }

    private let logger = Logger(subsystem: "com.myanimelist", category: "Authentication")

    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .signIn(.delegate(.showSignUp)):
                logger.debug("showSignUp")
                return .none

            case .signIn(.delegate(.signInUser(let request))):
                logger.debug("showSignUp: username: \(request.username)")
                return .none
                
            case .signIn:
                return .none

            }
        }
        
        Scope(state: \.signIn, action: /Action.signIn) {
            SignIn()
        }
    }
}
