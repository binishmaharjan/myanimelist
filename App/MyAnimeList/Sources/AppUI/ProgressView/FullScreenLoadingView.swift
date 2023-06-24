//
//  Created by Maharjan Binish on 2023/05/04.
//

import SwiftUI

// MARK: Modifier
extension View {
     public func fullScreenProgress(
        _ isInProgress: Bool,
        dimmedBackground: Bool = false,
        @ViewBuilder content: @escaping () -> some View = ProgressView.init
    ) -> some View {
        background {
            FullScreenLoadingView(isInProgress: isInProgress, dimmedBackground: dimmedBackground) {
                content()
                    .progressViewStyle(
                        .appDefault(
                            background: .ultraThinMaterial
                                .opacity(dimmedBackground ? 0 : 1)
                        )
                    )
                    .foregroundColor(Color.app(.primary))
            }
        }
    }
}

// MARK: FullscreenLoadingView
/// Loading Screen which make full screen uninteractable
private struct FullScreenLoadingView<Content: View>: UIViewControllerRepresentable {
    var isInProgress: Bool
    var dimmedBackground: Bool
    @ViewBuilder var content: () -> Content

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ viewController: UIViewController, context: Context) {
        context.coordinator.rootView = content()
        context.coordinator.view.backgroundColor = dimmedBackground ? .black.withAlphaComponent(0.3) : .clear

//        viewController.view.window?.isUserInteractionEnabled = !isInProgress

        if isInProgress, let window = viewController.view.window {
            window.addSubview(context.coordinator.view)
            context.coordinator.view.frame = window.bounds
        } else {
            context.coordinator.view.removeFromSuperview()
        }
    }

    func makeCoordinator() -> ContainerViewController {
        ContainerViewController(content: content())
    }

    final class ContainerViewController: UIHostingController<Content> {
        init(content: Content) {
            super.init(rootView: content)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: Preview
private struct FullScreenLoadingViewPreview: View {
    @State private var isInProgress = false
    @State private var dimmedBackground = true
    var body: some View {
        VStack {
            Toggle("In Progress", isOn: $isInProgress)
            Toggle("Dimmed Background", isOn: $dimmedBackground)
        }
        .padding(32)
        .onChange(of: isInProgress) { _ in
            guard isInProgress else {
                return
            }
            Task {
                try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
                isInProgress = false
            }
        }
        .tint(Color.app(.primary))
        .fullScreenProgress(isInProgress, dimmedBackground: dimmedBackground) {
            ProgressView {
                if dimmedBackground {
                    Text("Loading")
                }
            }
        }
    }
}

#Preview {
    FullScreenLoadingViewPreview()
}
