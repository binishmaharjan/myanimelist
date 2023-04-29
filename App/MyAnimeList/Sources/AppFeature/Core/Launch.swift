//
//  Created by Maharjan Binish on 2023/04/29.
//

import APIClient
import ComposableArchitecture
import Foundation
import UserDefaultsClient
import FeatureKit
import os.log

public struct Launch: Reducer {
    public struct State: Equatable {
        @PresentationState var destination: Destination.State?
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case needsDisplayTermsAndCondition
        }
        public enum Alert: Equatable {
            case randomAction
        }

        case destination(PresentationAction<Destination.Action>)
        case onAppear
        case fetchRequiredAppVersion
        case requiredAppVersionResponse(TaskResult<AppConfig>)
        case delegate(Delegate)
    }

    public struct Destination: Reducer {
        public enum State: Equatable {
            case alert(AlertState<Launch.Action.Alert>)

            public var id: AnyHashable {
                switch self {
                case let .alert(state):
                    return state.id
                }
            }
        }

        public enum Action: Equatable {
            case alert(Launch.Action.Alert)
        }

        public var body: some ReducerOf<Destination> {
            Reduce { state, action in
                print("Destination Body")
                return .none
            }
        }
    }

    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.userDefaultsClient) private var userDefaultsClient
    @Dependency(\.appVersion) private var currentAppVersion

    private let logger = Logger(subsystem: "com.myanimelist", category: "Launch")

    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                logger.debug("onAppear")
                return Effect.send(.fetchRequiredAppVersion)

            case .fetchRequiredAppVersion:
                return .task {
                    try await clock.sleep(for: .seconds(3))
                    logger.debug("fetchRequiredAppVersion")
                    return await .requiredAppVersionResponse(
                        TaskResult{
                            try await apiClient.fetchAppConfig().value
                        }
                    )
                }

            case .requiredAppVersionResponse(.success(let appConfig)):
                logger.debug("requiredAppVersionResponse: success")

                guard let requiredAppVersion = AppVersion.init(rawValue:appConfig.iOSVersion),
                      currentAppVersion < requiredAppVersion else {
                    return .none
                }

                return .send(.delegate(.needsDisplayTermsAndCondition))

            case .requiredAppVersionResponse(.failure):
                logger.debug("requiredAppVersionResponse: failure")
                state.destination = .alert(.appVersionErrorAlert())
                return .none

            case .destination:
                logger.debug("destination:")
                return .none

            case .delegate:
                logger.debug("delegate")
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

// MARK: Alerts
extension AlertState where Action == Launch.Action.Alert {
    fileprivate static func appVersionErrorAlert() -> AlertState {
        AlertState {
            TextState("Error")
        } message: {
            TextState("Couldn't fetch the data.")
        }
    }
}
