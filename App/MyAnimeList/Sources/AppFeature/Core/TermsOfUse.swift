//
//  Created by Maharjan Binish on 2023/04/30.
//

import ComposableArchitecture
import Foundation
import os.log

public struct TermsOfUse: Reducer {
    public struct State: Equatable {
        var url = URL(string: "https://myanimelist.net/static/apiagreement.html")!
        var latestUpdateDate: Date
    }
    
    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case showLogin
        }
        case agreedButtonTapped
        case delegate(Delegate)
    }

    @Dependency(\.userDefaultsClient) private var userDefaultsClient

    private let logger = Logger(subsystem: "com.myanimelist", category: "TermsOFUse")
    
    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .agreedButtonTapped:
                logger.debug("agreedButtonTapped")
                userDefaultsClient.setTermsOfUseAgreedDate(state.latestUpdateDate)
                return .send(.delegate(.showLogin))

            case .delegate:
                logger.debug("delegate")
                return .none
            }
        }
    }
}
