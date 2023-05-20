//
//  Created by Maharjan Binish on 2023/05/20.
//

import SwiftUI
import ComposableArchitecture


extension View {
    public func appError<
        State: Equatable,
        Action: Equatable
    >(
        store: Store<PresentationState<State>, PresentationAction<Action>>,
        state toDestinationState: @escaping (State) -> AppErrorReducer.State?,
        action fromDestinationAction: @escaping (AppErrorReducer.Action) -> Action
    ) -> some View {
        self.modifier(
            AppErrorModifier(
                store: store,
                toDestinationState: toDestinationState,
                fromDestinationAction: fromDestinationAction
            )
        )
    }
}

// MARK: Modifier
private struct AppErrorModifier<
    State: Equatable,
    Action: Equatable
>: ViewModifier {
    let store: Store<PresentationState<State>, PresentationAction<Action>>
    @ObservedObject var viewStore: ViewStore<PresentationState<State>, PresentationAction<Action>>
    let toDestinationState: (State) -> AppErrorReducer.State?
    let fromDestinationAction: (AppErrorReducer.Action) -> Action

    init(
        store: Store<PresentationState<State>, PresentationAction<Action>>,
        toDestinationState: @escaping (State) -> AppErrorReducer.State?,
        fromDestinationAction: @escaping (AppErrorReducer.Action) -> Action
    ) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self.toDestinationState = toDestinationState
        self.fromDestinationAction = fromDestinationAction
    }

    func body(content: Content) -> some View {
        let alertState = self.viewStore.wrappedValue.flatMap(self.toDestinationState)
        return content
            .fullScreenCover(
                isPresented: Binding(
                    get: {
                        guard let appErrorReducerState = self.viewStore.wrappedValue.flatMap(self.toDestinationState) else {
                            return false
                        }
                        return appErrorReducerState.appErrorState.isFullScreenError
                    },
                    set: { newState in
                        if !newState, self.viewStore.wrappedValue != nil {
                            self.viewStore.send(.dismiss)
                        }
                    }
                )
            ) {
                let appErrorState = self.viewStore.wrappedValue.flatMap(self.toDestinationState)?.appErrorState
                return fullScreenContent(appErrorState: appErrorState)
            }
            .alert(
               Text("Error"),
               isPresented: Binding(
                get: {
                    guard let appErrorReducerState = self.viewStore.wrappedValue.flatMap(self.toDestinationState) else {
                        return false
                    }
                    return appErrorReducerState.appErrorState.isAlertError
                },
                set: { newState in
                    if !newState, self.viewStore.wrappedValue != nil {
                      self.viewStore.send(.dismiss)
                    }
                  }
               ),
               presenting: alertState,
               actions: { appErrorReducerState in
                   if appErrorReducerState.appErrorState.isUndefined {
                       Button {
                           self.viewStore.send(.presented(self.fromDestinationAction(.retry)))
                       } label: {
                           Text("Retry")
                       }
                   }

                   Button {
                       self.viewStore.send(.presented(self.fromDestinationAction(.cancel)))
                   } label: {
                       Text("Cancel")
                   }
               },
               message: { appErrorState in
                   appErrorState.appErrorState.value.errorDescription.map(Text.init)
               }
            )
    }

    @ViewBuilder
    private func fullScreenContent(appErrorState: AppErrorState?) -> some View {
        if case .api(let apiError) = appErrorState?.value {
            if apiError.code == .serverError {
                ServerErrorView(
                    message: appErrorState?.value.errorDescription ?? "",
                    retryAction: { viewStore.send(.presented(self.fromDestinationAction(.retry))) }
                )
            } else if apiError.code == .underMaintenance {
                MaintenanceView(
                    message: appErrorState?.value.errorDescription ?? "",
                    retryAction: { viewStore.send(.presented(self.fromDestinationAction(.retry))) }
                )
            }
        }
    }
}

// MARK: App Error + Reducer
public struct AppErrorReducer: Reducer {
    public struct State: Equatable {
        public init(appErrorState: AppErrorState) {
            self.appErrorState = appErrorState
        }
        var appErrorState: AppErrorState
    }

    public enum Action: Equatable {
        case retry
        case cancel
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .retry, .cancel:
                return .none
            }
        }
    }
}
