//
//  Created by Maharjan Binish on 2023/04/27.
//

import ComposableArchitecture
import Foundation
import os.log

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

    private let logger = Logger(subsystem: "com.myanimelist", category: "Root")

    public var body: some ReducerProtocol<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                state.phase = .launch(.init())
                return .none

            case .phase(.launch(.delegate(.needsTermsAndCondition))):
                logger.debug("termsAndCondition")
                return .none

            case .phase(.launch(.delegate(.login))):
                logger.debug("login")
                return .none

            case .phase:
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
