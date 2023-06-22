//
//  Created by Maharjan Binish on 2023/04/27.
//

import AppUI
import ComposableArchitecture
import SwiftUI
import AuthenticationFeature

public struct RootView: View {
    struct ViewState: Equatable {
        var phase: Root.State.Phase?

        init(state: Root.State) {
            self.phase = state.phase
        }
    }
    
    public init(store: StoreOf<Root>) {
        self.store = store
    }

    private let store: StoreOf<Root>

    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            ZStack {
                IfLetStore(store.scope(state: \.phase, action: Root.Action.phase)) { phaseStore in
                    SwitchStore(phaseStore) {
                        // Launch
                        CaseLet(state: /Root.State.Phase.launch, action: Root.Action.Phase.launch) { store in
                            LaunchView(store: store)
                        }

                        // Terms Of use
                        CaseLet(state: /Root.State.Phase.termsOfUse, action: Root.Action.Phase.termsOfUse) { store in
                            TermsOfUseView(store: store)
                        }

                        // Authentication
                        CaseLet(state: /Root.State.Phase.authentication, action: Root.Action.Phase.authentication) { store in
                            AuthenticationView(store: store)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

#Preview {
    RootView(store: .init(initialState: .init(), reducer: Root()))
}
