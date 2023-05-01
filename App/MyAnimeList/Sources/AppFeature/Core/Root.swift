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
            case termsOfUse(TermsOfUse.State)
        }

        var phase: Phase?
        public init() {}
    }

    public enum Action: Equatable {
        public enum Phase: Equatable {
            case launch(Launch.Action)
            case termsOfUse(TermsOfUse.Action)
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

            case .phase(.launch(.delegate(.needsTermsOfUseAgreement(let latestUpdateDate)))):
                logger.debug("termsAndCondition: \(latestUpdateDate)")
                state.phase = .termsOfUse(.init(latestUpdateDate: latestUpdateDate))
                return .none

            case .phase(.launch(.delegate(.login))),
                 .phase(.termsOfUse(.delegate(.login))):
                logger.debug("login")
                return .none

            case .phase:
                return .none
            }
        }
        .ifLet(\.phase, action: /Action.phase) {
            Scope(state: /State.Phase.launch, action: /Action.Phase.launch) {
                Launch()
            }
            Scope(state: /State.Phase.termsOfUse, action: /Action.Phase.termsOfUse) {
                TermsOfUse()
            }
        }
    }
}
