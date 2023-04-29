//
//  Created by Maharjan Binish on 2023/04/29.
//

import APIClient
import ComposableArchitecture
import Foundation

public struct Launch: Reducer {
    public struct State: Equatable {

    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {

        }
        case onAppear
        case fetchRequiredAppVersion
        case requiredAppVersionResponse(TaskResult<AppConfig>)
        case delegate(Delegate)
    }

    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.continuousClock) private var clock

    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
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
                print("appVersion: success")
                return .none

            case .requiredAppVersionResponse(.failure):
                print("appVersion: failure")
                return .none

            case .delegate:
                print("delegate")
                return .none
            }
        }

    }
}

//// MARK: Destination
//extension Launch {
//    public struct Destination: Reducer {
//        public enum State: Equatable, Identifiable {
//            case alert(AlertState<Launch.Action.Alert>)
//
//            public var id: AnyHashable {
//                switch self {
//                case let .alert(state):
//                    return state.id
//                }
//            }
//        }
//
//        public enum Action: Equatable {
//            case alert(Launch.Action.Alert)
//        }
//
//        public var body: some ReducerOf<Destination> {
//            Reduce { state, action in
//                return .none
//            }
//        }
//    }
//}
