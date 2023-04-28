//
//  Created by Maharjan Binish on 2023/04/29.
//

import ComposableArchitecture
import Foundation

public struct Launch: Reducer {
    public struct State: Equatable {

    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {

        }
        case onAppear
        case delegate(Delegate)
    }

    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                print("Launch On Appear")
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
