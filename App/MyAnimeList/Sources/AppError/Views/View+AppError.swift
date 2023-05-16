//
//  Created by Maharjan Binish on 2023/05/07.
//

import SwiftUI

//public extension View {
//    func appError(_ appErrorState: Binding<AppErrorState?>) -> some View {
//        modifier(AppErrorModifier(appErrorState: appErrorState))
//    }
//}
//
//private struct AppErrorModifier: ViewModifier {
//    @Binding var appErrorState: AppErrorState?
//
//    func body(content: Content) -> some View {
//        content
//            .fullScreenCover(
//                isPresented: $appErrorState.isFullScreenPresented,
//                onDismiss: appErrorState?.dismissalAction
//            ) {
//                fullScreenContent
//                    .onDisappear {
//                        // `appErrorState`プロパティが更新されアラート表示に切り替える際に必要になる処理。
//                        // フルスクリーン表示が閉じられてから`appErrorState`を更新しないとアラートが表示されなくなる。
//                        // (フルスクリーンを閉じるアニメーションの途中にアラートを表示しようと試みてうまく表示されないのかもしれない)
//                        // 一旦`nil`を設定し、次のランループで元々の更新内容を再度設定する。
//                        DispatchQueue.main.async {
//                            self.appErrorState = appErrorState
//                        }
//                        appErrorState = nil
//                    }
//            }
//            .alert(
//                isPresented: $appErrorState.isAlertPresented,
//                error: appErrorState?.value
//            ) { [appErrorState] appError in
//                switch appError {
//                case .api:
//                    Button(appErrorState?.singleDismissalLabel ?? "", role: .cancel) {
//                        appErrorState?.dismissalAction()
//                    }
//                case .network, .general:
//                    Button("Retry") {
//                        appErrorState?.retryAction()
//                    }
//                    Button("Cancel") {
//                        appErrorState?.dismissalAction()
//                    }
//                case .localSystem:
//                    Button(appErrorState?.singleDismissalLabel ?? "") {
//                        appErrorState?.dismissalAction()
//                    }
//                }
//            } message: { appError in
//                Text(appError.recoverySuggestion ?? "")
//            }
//    }
//
//    @ViewBuilder private var fullScreenContent: some View {
//        if case .api(let apiError) = appErrorState?.value {
//            if apiError.code == .serverError {
//                ServerErrorView(
//                    message: appErrorState?.value.errorDescription ?? "",
//                    retryAction: appErrorState?.retryAction ?? {}
//                )
//            } else if apiError.code == .notFound {
//                NotFoundErrorView(
//                    message: appErrorState?.value.errorDescription ?? "",
//                    retryAction: appErrorState?.retryAction ?? {}
//                )
//            } else if apiError.code == .underMaintenance {
//                MaintenanceView(
//                    message: appErrorState?.value.errorDescription ?? "",
//                    retryAction: appErrorState?.retryAction ?? {}
//                )
//            }
//        }
//    }
//}
//
//extension Binding where Value == AppErrorState? {
//    var isFullScreenPresented: Binding<Bool> {
//        Binding<Bool>(
//            get: {
//                if let wrappedValue {
//                    return wrappedValue.isFullScreenError
//                }
//                return false
//            },
//            set: { isPresented, transaction in
//                // もし`nil`を設定してしまうと、アラートが表示されなくなってしまう。
//                // 反対に、アラートからフルスクリーンのエラー表示をする場合は、上記のような考慮をしなくても正しく表示される。
//                // (非表示になる際のアニメーションの長さが関係している？)
//                guard !isPresented else {
//                    return
//                }
//                if let wrappedValue, wrappedValue.isFullScreenError {
//                    self.transaction(transaction).wrappedValue = nil
//                }
//            }
//        )
//    }
//
//    var isAlertPresented: Binding<Bool> {
//        Binding<Bool>(
//            get: {
//                if let wrappedValue {
//                    return !wrappedValue.isFullScreenError
//                }
//                return false
//            },
//            set: { isPresented, transaction in
//                if !isPresented {
//                    self.transaction(transaction).wrappedValue = nil
//                }
//            }
//        )
//    }
//}
//
//
//struct AppErrorModifier_Previews: PreviewProvider {
//    private struct Preview: View {
//        @State private var appErrorState: AppErrorState?
//
//        var body: some View {
//            VStack(spacing: 16) {
//                Text("appError: \((appErrorState?.value).debugDescription)")
//
//                Group {
//                    Button("General Error") {
//                        appErrorState = AppErrorState(.general) { /* Finished */ }
//                    }
//
//                    Button("Server Error") {
//                        appErrorState = AppErrorState(
//                            .api(.init(status: 404, code: .serverError, message: "Error"))
//                        ) {
//                            appErrorState = nil
//                        }
//                    }
//
//                    Button("Maintenance Error") {
//                        appErrorState = AppErrorState(
//                            .api(.init(status: 404, code: .underMaintenance, message: "Error"))
//                        ) {
//                            appErrorState = nil
//                        }
//                    }
//
//                    Button("Not Found Error") {
//                        appErrorState = AppErrorState(
//                            .api(.init(status: 404, code: .notFound, message: "Error"))
//                        ) {
//                            appErrorState = nil
//                        }
//                    }
//                }
//                .appError($appErrorState)
//            }
//        }
//    }
//
//    static var previews: some View {
//        Preview()
//    }
//}

import ComposableArchitecture

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
