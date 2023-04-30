//
//  Created by Maharjan Binish on 2023/04/30.
//

import SwiftUI

/// アプリ内で使用される色定義。色空間は`sRGB`。
///
/// SwiftUIでの使用例:
/// ```swift
/// ZStack {
///     // `AppColor`を直接使用する
///     AppColor.wh1
///     Text("Hello, World!")
///         // `SwiftUI.Color`が要求される場面では、
///         // 拡張された`app()`メソッドを経由して`AppColor`を使用する。
///         // `Color(appColor: .bk1)`では、
///         // "foreground color color..."と冗長な表記になる。
///         .foregroundColor(.app(.bk1))
///         .background {
///             RoundedRectangle(cornerRadius: 10)
///                 .fill(Color(appColor: .primary))
///         }
/// }
/// ```
///
/// UIKitでの使用例:
/// ```swift
/// let view = UIView()
/// view.backgroundColor = .app(.gr5)
/// view.layer.shadowColor = UIColor(appColor: .bk2).cgColor
/// ```
public enum AppColor: String, CaseIterable, View {
    /// \#2e55a5
    case primary
    /// \#6234D5
    case accent
    /// \#452A7C
    case shadow
    /// \#4f6fb8
    case blue1
    /// \#c6d0e9
    case blue2
    /// \#ffffff
    case white1
    /// \#000000
    case black1
    /// \#a2a0a2
    case gray1

    public var body: Color {
        Color(appColor: self)
    }
}

extension Color {
    public init(appColor: AppColor) {
        self.init(appColor.rawValue, bundle: .module)
    }

    public static func app(_ appColor: AppColor) -> Self {
        return Color(appColor: appColor)
    }
}

extension UIColor {
    public convenience init(appColor: AppColor) {
        self.init(named: appColor.rawValue, in: .module, compatibleWith: nil)!
    }

    public static func app(_ appColor: AppColor) -> UIColor {
        return UIColor(appColor: appColor)
    }
}

struct AppColor_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
            ForEach(AppColor.allCases, id: \.self) { color in
                color
                    .border(Color.gray)
                    .overlay {
                        Text(color.rawValue)
                            .foregroundColor(.app(color))
                            .colorInvert()
                    }
                    .frame(height: 80)
            }
        }
        .padding()
    }
}
