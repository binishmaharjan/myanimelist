//
//  Created by Maharjan Binish on 2023/04/27.
//

import ComposableArchitecture
import Foundation
import os.log
import AuthenticationFeature

public struct Root: Reducer {
    public struct State: Equatable {
        public enum Phase: Equatable {
            case launch(Launch.State)
            case termsOfUse(TermsOfUse.State)
            case authentication(Authentication.State)
        }

        var phase: Phase?
        public init() {}
    }

    public enum Action: Equatable {
        public enum Phase: Equatable {
            case launch(Launch.Action)
            case termsOfUse(TermsOfUse.Action)
            case authentication(Authentication.Action)
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

            case .phase(.launch(.delegate(.showLogin))),
                 .phase(.termsOfUse(.delegate(.showLogin))):
                logger.debug("login")
                state.phase = .authentication(.init())
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
            Scope(state: /State.Phase.authentication, action: /Action.Phase.authentication) {
                Authentication()
            }
        }

    }
}
