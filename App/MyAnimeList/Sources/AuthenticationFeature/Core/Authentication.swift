//
//  Created by Maharjan Binish on 2023/05/03.
//

import APIClient
import AppError
import Foundation
import ComposableArchitecture
import os.log

public struct Authentication: Reducer {
    public struct State: Equatable {
        public enum Phase: Equatable {
            case signIn
            case signUp
        }

        public init() { }

        var signIn: SignIn.State = SignIn.State()
        var signUp: SignUp.State = SignUp.State()
        var phase: Phase = .signIn
        var isLoading = false
        @PresentationState var destination: Destination.State?
    }

    public enum Action: Equatable {
        case signIn(SignIn.Action)
        case signUp(SignUp.Action)
        case authenticateResponse(TaskResult<User>)
        case toggleLoading(Bool)
        case destination(PresentationAction<Destination.Action>)
    }

    public init(){ }

    @Dependency(\.continuousClock) private var clock
    @Dependency(\.apiClient) private var apiClient

    private let logger = Logger(subsystem: "com.myanimelist", category: "Authentication")

    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .signIn(.delegate(.showSignUp)):
                logger.debug("showSignUp")
                state.phase = .signUp
                return .none

            case .signIn(.delegate(.signInUser(let request))):
                logger.debug("signInUser")
                state.isLoading = true

                return .task {
                    try await clock.sleep(for: .seconds(2))
                    return await .authenticateResponse(
                        TaskResult {
                            try await apiClient.signIn(request).value
                        }
                    )
                }

            case .signUp(.delegate(.showSignIn)):
                state.phase = .signIn
                logger.debug("showSignIn")
                return .none

            case .signUp(.delegate(.signUpUser(let request))):
                logger.debug("signUpUser")
                state.isLoading = true

                return .task {
                    try await clock.sleep(for: .seconds(2))
                    return await .authenticateResponse(
                        TaskResult {
                            try await apiClient.signUp(request).value
                        }
                    )
                }

            case .toggleLoading(let isLoading):
                logger.debug("toggleLoading \(isLoading)")
                state.isLoading = isLoading

                return .none

            case .authenticateResponse(.success(let user)):
                logger.debug("authenticateResponse: user \(user.id)")
                state.isLoading = false

                return .none


            case .authenticateResponse(.failure(let error)):
                logger.debug("authenticateResponse: failure")
                state.isLoading = false

                let appErrorState = AppErrorState(AppError(error: error))!
                state.destination = .appError(AppErrorReducer.State(appErrorState: appErrorState))

                return .none

            case .destination(.presented(.appError(.retry))):
                print("Retry")
                state.destination = nil
                return .none

            case .destination(.presented(.appError(.cancel))):
                print("Cancel")
                state.destination = nil
                return .none

            case .signIn, .signUp, .destination:
                return .none
            }
        }
        
        Scope(state: \.signIn, action: /Action.signIn) {
            SignIn()
        }

        Scope(state: \.signUp, action: /Action.signUp) {
            SignUp()
        }
    }
}

// MARK: Destination
extension Authentication {
    public struct Destination: Reducer {
        public enum State: Equatable {
            case appError(AppErrorReducer.State)
        }

        public enum Action: Equatable {
            case appError(AppErrorReducer.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: /State.appError, action: /Action.appError) {
                AppErrorReducer()
            }
        }
    }
}
