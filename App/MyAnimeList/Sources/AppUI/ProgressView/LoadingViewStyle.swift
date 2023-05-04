//
//  Created by Maharjan Binish on 2023/05/04.
//

import SwiftUI
import Lottie
import UIKit

// MARK: LottieView
/// View to display lottie json
fileprivate struct LottieView: UIViewRepresentable {
    fileprivate typealias UIViewType = UIView
    var filename: String

    fileprivate func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        let animationView =  LottieAnimationView()
        let animation = LottieAnimation.named(filename, bundle: .module)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .repeat(.infinity)
        animationView.play()


        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    fileprivate func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {

    }
}

// MARK: Modifier
extension ProgressViewStyle {
    public static func appDefault<B: ShapeStyle>(background: B) -> Self where Self == LoadingViewStyle<B> {
        LoadingViewStyle(background: background)
    }
}

// MARK: Preset Styles
extension ProgressViewStyle where Self == LoadingViewStyle<Color> {
    public static var clear: Self {
        LoadingViewStyle(background: .clear)
    }
}

extension ProgressViewStyle where Self == LoadingViewStyle<Material> {
    public static var appDefault: Self {
        LoadingViewStyle(background: .ultraThinMaterial)
    }
}

// MARK: Custom Progress View Style
public struct LoadingViewStyle<Background: ShapeStyle>: ProgressViewStyle {
    public init(background: Background) {
        self.background = background
    }

    var background: Background

    private let indicatorScale = 1.5
    private let padding = 28.0

    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 16 * indicatorScale) {
            LottieView(filename: "loading")
                .frame(width: 36, height: 36)
                .scaleEffect(indicatorScale)

            configuration.label
                .font(.app(.title2))
                .padding(.bottom, -(padding / indicatorScale))
        }
        .padding(padding * indicatorScale)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(background)
                .padding()
                .shadow(radius: 5)
        }
    }
}

// MARK: Preview
struct LoadingViewStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ProgressView()
                .progressViewStyle(.appDefault(background: .ultraThinMaterial))

            ProgressView("Clear")
                .progressViewStyle(.clear)
                .foregroundColor(.pink)

            ProgressView("Default")
                .progressViewStyle(.appDefault)
                .foregroundColor(Color.app(.primary))

            ProgressView("Color")
                .progressViewStyle(.appDefault(background: Color.app(.blue2)))
        }
    }
}
