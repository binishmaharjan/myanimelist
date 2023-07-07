//
//  Created by Maharjan Binish on 2023/04/30.
//

import SwiftUI

private struct BottomFloatingButtonModifier<Caption: View>: ViewModifier {
    var titleKey: LocalizedStringKey
    var isDisabled: Bool
    var action: () -> Void
    var caption: Caption

    @State private var isKeyboardPresented = false

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                isKeyboardPresented = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                isKeyboardPresented = false
            }
            .safeAreaInset(edge: .bottom) {
                if !isKeyboardPresented {
                    bottomButton
                }
            }
    }

    private var bottomButton: some View {
        VStack(spacing: 18) {
            Button(action: action) {
                AngularButton(title: titleKey)
            }
            .disabled(isDisabled)

            caption
        }
        .disabled(isDisabled)
        .padding([.horizontal, .top], 24)
        .padding(.bottom, 24)
        .background {
            Color(appColor: .white1)
                .background(.ultraThinMaterial)
                .backgroundColor(opacity: 0.4)
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: .app(.shadow).opacity(0.05), radius: 6 / UITraitCollection.current.displayScale, x: 0, y: -4)
        }
    }
}

extension View {
    /// このviewの最下部に`PrimaryButtonStyle(size: .large)`のボタンとその上部に`caption`引数で渡された`Caption`、
    /// およびそれら囲む枠を幅いっぱいに配置する。
    public func bottomFloatingButton(
        _ titleKey: LocalizedStringKey,
        disabled isDisabled: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder caption: @escaping () -> some View
    ) -> some View {
        modifier(BottomFloatingButtonModifier(titleKey: titleKey, isDisabled: isDisabled, action: action, caption: caption()))
    }

    /// このviewの最下部に`PrimaryButtonStyle(size: .large)`のボタンとそれを囲む枠を幅いっぱいに配置する。
    public func bottomFloatingButton(
        _ titleKey: LocalizedStringKey,
        disabled isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        modifier(BottomFloatingButtonModifier(titleKey: titleKey, isDisabled: isDisabled, action: action, caption: EmptyView()))
    }
}

// MARK: Preview
private struct BottomFloatingButtonPreview: View {
    @State private var isScrollView = true
    @State private var isCaptionPresented = false

    var body: some View {
        VStack {
            Toggle("ScrollView", isOn: $isScrollView)
            Toggle("Caption", isOn: $isCaptionPresented)
            if isScrollView {
                scrollView
            } else {
                TextField("", text: .constant(""))
            }
        }
        .tint(.app(.primary))
        .bottomFloatingButton("Next") {
        } caption: {
            if isCaptionPresented {
                caption
            }
        }
    }

    private var scrollView: some View {
        ScrollView {
            TextField("", text: .constant(""))
            ForEach(0..<100) { _ in
                Text("Hello, world!")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var caption: some View {
        Text("Caption text")
            .font(.app(.body2))
    }
}

//@available(iOS 17.0, *)
//#Preview {
//    NavigationView {
//        BottomFloatingButtonPreview()
//            .navigationTitle("BottomFloatingButton")
//            .navigationBarTitleDisplayMode(.inline)
//    }
//    .previewDevice(.init(rawValue: "iPhone 13"))
//    .previewDisplayName("iPhone 13")
//}
//
//@available(iOS 17.0, *)
//#Preview {
//    NavigationView {
//        BottomFloatingButtonPreview()
//            .navigationTitle("BottomFloatingButton")
//            .navigationBarTitleDisplayMode(.inline)
//    }
//    .previewDevice(.init(rawValue: "iPhone 8"))
//    .previewDisplayName("iPhone 8")
//}

