//
//  Created by Maharjan Binish on 2023/04/30.
//

import SwiftUI

extension Font {
    /// アプリ内で利用されるフォントの定義。
    ///
    /// SwiftUIでの使用例:
    /// ```swift
    /// VStack {
    ///     Text("Hello, world!")
    ///         .font(.app(.title))
    ///     Text("Hello, world!")
    ///         .font(.app(.body2))
    /// ```
    ///
    /// UIKitでの使用例:
    /// ```swift
    /// let label = UILabel()
    /// label.font = .preferredFont(forAppTextStyle: .body)
    /// ```
    public enum AppTextStyle: Hashable {
        /// Size is 40 points and weight is bold.
        case largeTitle
        /// Size is 20 points and weight is semibold.
        case title
        /// Size is 18 points and weight is semibold.
        case title2
        /// Size is 16 points and weight is semibold.
        case title3
        /// Size is 14 points and weight is semibold.
        case title4
        /// Size is 12 points and weight is semibold.
        case title5

        /// Size is 18 points and weight is regular.
        case body
        /// Size is 16 points and weight is regular.
        case body2
        /// Size is 14 points and weight is regular.
        case body3
        /// Size is 12 points and weight is regular.
        case body4
    }
}

extension Font.AppTextStyle {
    public var size: CGFloat {
        switch self {
        case .largeTitle:
            return 40.0
        case .title:
            return 20.0
        case .title2:
            return 18.0
        case .title3:
            return 16.0
        case .title4:
            return 14.0
        case .title5:
            return 12.0

        case .body:
            return 18.0
        case .body2:
            return 16.0
        case .body3:
            return 14.0
        case .body4:
            return 12.0
        }
    }

    public var weight: Font.Weight {
        switch self {
        case .largeTitle:
            return .bold
        case .title, .title2, .title3, .title4, .title5:
            return .semibold
        case .body, .body2, .body3, .body4:
            return .regular
        }
    }
}

extension Font {
    public static func app(_ style: AppTextStyle, weight: Weight? = nil, design: Design = .default) -> Self {
        return .system(size: style.size, weight: weight ?? style.weight, design: design)
    }
}

extension UIFont {
    public static func preferredFont(forAppTextStyle style: Font.AppTextStyle) -> UIFont {
        if let weight = Weight(style.weight) {
            return .systemFont(ofSize: style.size, weight: weight)
        }
        return .systemFont(ofSize: style.size)
    }
}

extension UIFont.Weight {
    init?(_ weight: Font.Weight) {
        switch weight {
        case .ultraLight:
            self = .ultraLight
        case .thin:
            self = .thin
        case .light:
            self = .light
        case .regular:
            self = .regular
        case .medium:
            self = .medium
        case .semibold:
            self = .semibold
        case .bold:
            self = .bold
        case .heavy:
            self = .heavy
        case .black:
            self = .black
        default:
            return nil
        }
    }
}
