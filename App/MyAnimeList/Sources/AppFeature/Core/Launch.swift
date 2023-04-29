//
//  Created by Maharjan Binish on 2023/04/29.
//

import APIClient
import ComposableArchitecture
import Foundation

public struct Launch: Reducer {
    public struct State: Equatable {
        @PresentationState var destination: Destination.State?
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable { }
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

    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                print("onAppear")
                return Effect.send(.fetchRequiredAppVersion)

            case .fetchRequiredAppVersion:
                return .task {
                    try await clock.sleep(for: .seconds(3))
                    print("fetchRequiredAppVersion")
                    return await .requiredAppVersionResponse(
                        TaskResult{
                            try await apiClient.fetchAppConfig().value
                        }
                    )
                }

            case .requiredAppVersionResponse(.success(let appVersion)):
                print("requiredAppVersionResponse: success")
                return .none

            case .requiredAppVersionResponse(.failure):
                print("requiredAppVersionResponse: failure")
                state.destination = .alert(.appVersionErrorAlert())
                return .none

            case .destination(.dismiss):
                print("destination: dismiss")
                return .none

            case .destination:
                print("destination:")
                return .none

            case .delegate:
                print("delegate")
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
