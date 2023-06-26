//
//  Created by Maharjan Binish on 2023/05/02.
//

import ComposableArchitecture
import AppUI
import SwiftUI

struct SignInView: View {
    private struct AnimationOrder {
        var title: Bool = false
        var description: Bool = false
        var form: Bool = false
    }

    init(store: StoreOf<SignIn>) {
        self.store = store
    }

    @FocusState private var isUsernameFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @State private var circleInitialY = CGFloat.zero
    @State private var circleY = CGFloat.zero
    @State private var animationOrder = AnimationOrder()

    private var store: StoreOf<SignIn>

    var body: some View {
        /*
         TODO: Replace State with ViewState.
         Maybe because of @BindingState, it end in error.
         */
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text("Sign In")
                    .font(.app(.largeTitle))
                    .blendMode(.overlay)
                    .slideFadeIn(show: animationOrder.title, offset: 30)

                // Description
                Text("Welcome to MyAnimeList, the world's most active online anime and manga community and database. ")
                    .font(.app(.title5))
                    .foregroundStyle(.secondary)
                    .slideFadeIn(show: animationOrder.description, offset: 20)

                // Form
                Group {
                    // Email
                    TextField("Username", text: viewStore.binding(\.$username))
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .customField(icon: "envelope.open.fill")
                        .overlay {
                            GeometryReader { proxy in
                                let offset = proxy.frame(in: .named("stack")).minY + 32
                                Color.clear.preference(key: CirclePreferenceKey.self, value: offset)
                            }
                            .onPreferenceChange(CirclePreferenceKey.self) { value in
                                circleInitialY = value
                                circleY = value
                            }
                        }
                        .focused($isUsernameFocused)
                        .onChange(of: isUsernameFocused) { isEmailFocused in
                            if isEmailFocused {
                                withAnimation {
                                    circleY = circleInitialY
                                }
                            }
                        }

                    // Password
                    SecureField("Password", text: viewStore.binding(\.$password))
                        .textContentType(.password)
                        .customField(icon: "key.fill")
                        .focused($isPasswordFocused)
                        .onChange(of: isPasswordFocused, perform: { isPasswordFocused in
                            if isPasswordFocused {
                                withAnimation {
                                    circleY = circleInitialY + 70
                                }
                            }
                        })

                    // Sign In
                    Button {
                        viewStore.send(.signInButtonTapped)
                    } label: {
                        AngularButton(title: "Sign In")
                    }
                    .disabled(viewStore.state.isSignInButtonDisabled)

                    Divider()

                    // Info
                    Text("No account yet? **Sign up**")
                        .font(.app(.body3))
                        .foregroundColor(.primary.opacity(0.7))
                        .accentColor(.primary.opacity(0.7))
                        .onTapGesture {
                            viewStore.send(.signUpTextTapped)
                        }
                }
                .slideFadeIn(show: animationOrder.form, offset: 20)
            }
            .coordinateSpace(name: "stack")
            .padding(20)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial)
            .backgroundColor(opacity: 0.4)
            .cornerRadius(30)
            .background {
                VStack {
                    Circle().fill(.blue).frame(width: 68, height: 68)
                        .offset(x: 0, y: circleY)
                        .scaleEffect(animationOrder.title ? 1: 0.1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .outlineOverlay(cornerRadius: 30)
            .onAppear {
                isUsernameFocused = true
                viewStore.send(.onAppear)
                startInitialAnimations()
            }
        }
    }

    private func startInitialAnimations() {
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8).delay(0.2)) {
            animationOrder.title = true
        }
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8).delay(0.4)) {
            animationOrder.description = true
        }
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8).delay(0.6)) {
            animationOrder.form = true
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    SignInView(
        store: .init(
            initialState: .init(),
            reducer: SignIn()
        )
    )
}

