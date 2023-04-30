//
//  Created by Maharjan Binish on 2023/04/29.
//

import APIClient
import ComposableArchitecture
import Foundation
import UserDefaultsClient
import FeatureKit
import os.log

/*
 retry on error
 */

public struct Launch: Reducer {
    public struct State: Equatable {
        @PresentationState var destination: Destination.State?
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case needsTermsAndCondition
            case login
        }
        public enum Alert: Equatable {
            case forceUpdate
        }

        case destination(PresentationAction<Destination.Action>)
        case onAppear
        case fetchRequiredAppVersion
        case openForceUpdateURL
        case requiredAppVersionResponse(TaskResult<AppConfig>)
        case fetchAppInfo
        case appInfoResponse(TaskResult<AppInfo>)
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
                return .none
            }
        }
    }

    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.userDefaultsClient) private var userDefaultsClient
    @Dependency(\.appVersion) private var currentAppVersion
    @Dependency(\.openURL) private var openURL

    private let logger = Logger(subsystem: "com.myanimelist", category: "Launch")
    private let appStoreURL = URL(string: "https://apps.apple.com/jp/app/myanimelist-official/id1469330778?l=en")!

    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                logger.debug("onAppear")
                return Effect.send(.fetchRequiredAppVersion)

            case .fetchRequiredAppVersion:
                return .task {
                    try await clock.sleep(for: .seconds(1))
                    logger.debug("fetchRequiredAppVersion")
                    return await .requiredAppVersionResponse(
                        TaskResult{
                            try await apiClient.fetchAppConfig().value
                        }
                    )
                }

            case .destination(.presented(.alert(.forceUpdate))):
                logger.debug("alert: force update")
                state.destination = .alert(.forceUpdateAlert())
                return .send(.openForceUpdateURL)

            case .openForceUpdateURL:
                Task { await openURL(appStoreURL) }
                return .none

            case .requiredAppVersionResponse(.success(let appConfig)):
                logger.debug("requiredAppVersionResponse: success")
                guard let requiredAppVersion = AppVersion.init(rawValue:appConfig.iOSVersion),
                      currentAppVersion < requiredAppVersion else {
                    return .send(.fetchAppInfo)
                }

                state.destination = .alert(.forceUpdateAlert())
                return .none

            case .requiredAppVersionResponse(.failure):
                logger.debug("requiredAppVersionResponse: failure")
                state.destination = .alert(.responseErrorAlert())
                return .none

            case .fetchAppInfo:
                logger.debug("fetchAppInfo")
                return .task {
                    try await clock.sleep(for: .seconds(1))
                    return await .appInfoResponse(
                        TaskResult {
                            try await apiClient.fetchAppInfo().value
                        }
                    )
                }

            case .appInfoResponse(.success(let appInfo)):
                logger.debug("appInfoResponse: success")
                let currentTermsOfUseAgreedDate = userDefaultsClient.termsOfUseAgreedDate() ?? .distantPast
                guard currentTermsOfUseAgreedDate < appInfo.termsUpdatedAt else {
                    return .send(.delegate(.login))
                }

                return .send(.delegate(.needsTermsAndCondition))

            case .appInfoResponse(.failure):
                logger.debug("appInfoResponse: error")
                state.destination = .alert(.responseErrorAlert())
                return .none

            case .destination(.dismiss):
                logger.debug("destination: dismiss")
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
    fileprivate static func responseErrorAlert() -> AlertState {
        AlertState {
            TextState("Error")
        } message: {
            TextState("Couldn't fetch the data.")
        }
    }

    fileprivate static func forceUpdateAlert() -> AlertState {
        AlertState {
            TextState("Force Update")
        } actions: {
            ButtonState(role: .cancel, action: .send(.forceUpdate)) {
                TextState("Update")
            }
        } message: {
            TextState("A new version has been released. Please update the app.")
        }
    }
}
