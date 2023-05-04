//
//  Created by Maharjan Binish on 2023/05/02.
//

import ComposableArchitecture
import SwiftUI
import AppUI

public struct AuthenticationView: View {
    public init(store: StoreOf<Authentication>) {
        self.store = store
    }

    @State var appear = true
    @State var appearBackground = true

    private var store: StoreOf<Authentication>


    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(appear ? 1 : 0)
                    .ignoresSafeArea()

                GeometryReader { proxy in
                    Group {
                        switch viewStore.state.phase {
                        case .signIn:
                            SignInView(
                                store: store.scope(
                                    state: \.signIn,
                                    action: Authentication.Action.signIn
                                )
                            )

                        case .signUp:
                            SignUpView(
                                store: store.scope(
                                    state: \.signUp,
                                    action: Authentication.Action.signUp
                                )
                            )
                        }
                    }
                    .shadow(color: .app(.shadow).opacity(0.2), radius: 30, x: 0, y: 0)
                    .padding(20)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .offset(y: appear ? 0 : proxy.size.height)
                    .background(
                        Asset.Images.imgBlob1.swiftUIImage
                            .offset(x: 170, y: -60)
                            .opacity(appearBackground ? 1 : 0)
                            .offset(y: appearBackground ? -10 : 0)
                            .blur(radius: appearBackground ? 0 : 40)
                            .accessibilityHidden(true)
                    )
                }

                LoadingView()
                    .shadow(radius: 5)
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static let store: StoreOf<Authentication> = .init(initialState: .init(), reducer: Authentication())
    static var previews: some View {
        Group {
            AuthenticationView(store: store)

            AuthenticationView(store: store)
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
            .previewDisplayName("iPhone 8")
        }
    }
}
