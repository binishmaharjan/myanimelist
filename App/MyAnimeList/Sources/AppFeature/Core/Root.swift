//
//  Created by Maharjan Binish on 2023/04/27.
//

import ComposableArchitecture
import Foundation

public struct Root: Reducer {
    public struct State: Equatable {
        public init() {
        }
    }

    public enum Action: Equatable {
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce<State, Action> { state, action in
            return .none
        }
    }
}
