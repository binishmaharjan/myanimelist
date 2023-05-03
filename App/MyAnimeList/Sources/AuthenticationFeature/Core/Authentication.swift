//
//  Created by Maharjan Binish on 2023/05/03.
//

import Foundation
import ComposableArchitecture

public struct Authentication: Reducer {
    public struct State: Equatable {
        public init() { }
        var signIn: SignIn.State = SignIn.State()
    }

    public enum Action: Equatable{
        case signIn(SignIn.Action)
    }

    public init(){ }

    public var body: some ReducerOf<Authentication> {
        Reduce { state, action in
            switch action {
            case .signIn:
                return .none

            }
        }
        
        Scope(state: \.signIn, action: /Action.signIn) {
            SignIn()
        }
    }
}
