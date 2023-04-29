//
//  Created by Maharjan Binish on 2023/04/27.
//

import ComposableArchitecture
import Foundation

public struct Root: Reducer {
    public struct State: Equatable {
        public enum Phase: Equatable {
            case launch(Launch.State)
        }

        var phase: Phase?
        public init() {}
    }

    public enum Action: Equatable {
        public enum Phase: Equatable {
            case launch(Launch.Action)
        }
        case phase(Phase)
        case onAppear
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .phase(.launch):
                return .none

            case .onAppear:
                state.phase = .launch(.init())
                return .none
            }
        }

        Scope(state: \.phase, action: /Action.phase) {
            Reduce { _, _ in return .none }
                .ifCaseLet(/State.Phase.launch, action: /Action.Phase.launch) {
                    Launch()
                }
        }
    }
}
