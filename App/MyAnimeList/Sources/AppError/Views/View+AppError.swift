//
//  Created by Maharjan Binish on 2023/05/07.
//

import SwiftUI
import ComposableArchitecture

extension View {
    public func appError<State: Equatable, Action: Equatable>(
        store: Store<PresentationState<State>, PresentationAction<Action>>,
        state toDestinationState: @escaping (State) -> AppErrorReducer.State?,
        action fromDestinationAction: @escaping (AppErrorReducer.Action) -> Action
    ) -> some View {
        self.modifier(
            AppErrorModifier(
                viewStore: ViewStore(store, observe:  { $0 }),
                toDestinationState: toDestinationState,
                fromDestinationAction: fromDestinationAction)
        )
    }
}

private struct AppErrorModifier<State, Action>: ViewModifier {
    @StateObject var viewStore: ViewStore<PresentationState<State>, PresentationAction<Action>>
    let toDestinationState: (State) -> AppErrorReducer.State?
    let fromDestinationAction: (AppErrorReducer.Action) -> Action

    func body(content: Content) -> some View {
        let alertState = self.viewStore.wrappedValue.flatMap(self.toDestinationState)
        return content
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
}
//private struct PresentationAlertModifier<State, Action, ButtonAction>: ViewModifier {
//  @StateObject var viewStore: ViewStore<PresentationState<State>, PresentationAction<Action>>
//  let toDestinationState: (State) -> AlertState<ButtonAction>?
//  let fromDestinationAction: (ButtonAction) -> Action
//
//  func body(content: Content) -> some View {
//    let id = self.viewStore.id
//    let alertState = self.viewStore.wrappedValue.flatMap(self.toDestinationState)
//    content.alert(
//      (alertState?.title).map(Text.init) ?? Text(""),
//      isPresented: Binding( // TODO: do proper binding
//        get: { self.viewStore.wrappedValue.flatMap(self.toDestinationState) != nil },
//        set: { newState in
//          if !newState, self.viewStore.wrappedValue != nil, self.viewStore.id == id {
//            self.viewStore.send(.dismiss)
//          }
//        }
//      ),
//      presenting: alertState,
//      actions: { alertState in
//        ForEach(alertState.buttons) { button in
//          Button(role: button.role.map(ButtonRole.init)) {
//            switch button.action.type {
//            case let .send(action):
//              if let action = action {
//                self.viewStore.send(.presented(self.fromDestinationAction(action)))
//              }
//            case let .animatedSend(action, animation):
//              if let action = action {
//                _ = withAnimation(animation) {
//                  self.viewStore.send(.presented(self.fromDestinationAction(action)))
//                }
//              }
//            }
//          } label: {
//            Text(button.label)
//          }
//        }
//      },
//      message: {
//        $0.message.map(Text.init) ?? Text("")
//      }
//    )
//  }
//}
extension Binding where Value == AppErrorState? {
    var isFullScreenPresented: Binding<Bool> {
        .init(
            get: {
                if let wrappedValue {
                    return wrappedValue.isFullScreenError
                }
                return false
            },
            set: { isPresented, transaction in
                guard !isPresented else {
                    return
                }
                if let wrappedValue, wrappedValue.isFullScreenError {
                    self.transaction(transaction).wrappedValue = nil
                }
            }
        )
    }

    var isAlertPresented: Binding<Bool> {
        .init(
            get: {
                if let wrappedValue {
                    return !wrappedValue.isFullScreenError
                }
                return false
            },
            set: { isPresented, transaction in
                if !isPresented {
                    self.transaction(transaction).wrappedValue = nil
                }
            }
        )
    }
}

// MARK: App Error + Composable Architecture
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

public struct AppErrorView: View {
    public init(store: StoreOf<AppErrorReducer>) {
        self.store = store
    }
    private var store: StoreOf<AppErrorReducer>

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.appErrorState.isMaintenance {
                MaintenanceView(
                    message: viewStore.appErrorState.value.errorDescription!) {
                        viewStore.send(.retry)
                    }
            } else if viewStore.appErrorState.isServerError {
                ServerErrorView(
                    message: viewStore.appErrorState.value.errorDescription!) {
                        viewStore.send(.retry)
                    }
            } else if viewStore.appErrorState.isNotFoundError {
                NotFoundErrorView(
                    message: viewStore.appErrorState.value.errorDescription!) {
                        viewStore.send(.cancel)
                    }
            } else {
                Text("Error")
            }
        }
    }
}
