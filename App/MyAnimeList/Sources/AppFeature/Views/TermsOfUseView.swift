//
//  Created by Maharjan Binish on 2023/04/30.
//

import AppUI
import ComposableArchitecture
import SwiftUI

public struct TermsOfUseView: View {
    public var store: StoreOf<TermsOfUse>

    public var body: some View {
        WithViewStore(store, observe:  { $0 }) { viewStore in
            AgreementViewRepresentable(url: viewStore.state.url) {
                viewStore.send(.agreedButtonTapped)
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: UIViewRepresentable
struct AgreementViewRepresentable: UIViewControllerRepresentable {
    var url: URL
    var agreementAction: (() -> Void)

    func makeUIViewController(context: Context) -> AppNavigationController {
        let agreementView = AgreementView(url: url, agreementAction: agreementAction)
            .navigationTitle("利用規約")
        return AppNavigationController(rootViewController: UIHostingController(rootView: agreementView))
    }

    func updateUIViewController(_ uiView: AppNavigationController, context: Context) {}
}

// MARK: Terms of Use Content
private struct AgreementView: View {
    init(url: URL, agreementAction: @escaping () -> Void) {
        self.url = url
        self.agreementAction = agreementAction
    }

    var url: URL
    var agreementAction: () -> Void

    private var titleKey: LocalizedStringKey = ""
    private var isBackButtonHidden = false

    @State private var isAgreementButtonEnabled = false

    var body: some View {
        WebView(url: url) {
            isAgreementButtonEnabled = true
        }
        .navigationTitle(titleKey)
        .navigationBarBackButtonHidden(isBackButtonHidden)
        .bottomFloatingButton("同意", disabled: !isAgreementButtonEnabled, action: agreementAction)
    }

    func navigationTitle(_ titleKey: LocalizedStringKey) -> Self {
        var `self` = self
        self.titleKey = titleKey
        return self
    }
}

// MARK: Preview
public struct TermsOfUseView_Previews: PreviewProvider {
    public static var previews: some View {
        TermsOfUseView(
            store: .init(
                initialState: .init(latestUpdateDate: .distantPast),
                reducer: TermsOfUse()
            )
        )
    }
}
