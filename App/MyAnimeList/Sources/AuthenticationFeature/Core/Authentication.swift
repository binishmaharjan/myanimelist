//
//  Created by Maharjan Binish on 2023/05/03.
//

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
            case .signIn(.delegate(.signUp)):
                logger.debug("signUp")
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
