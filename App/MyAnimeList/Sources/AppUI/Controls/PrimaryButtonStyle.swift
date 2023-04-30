//
//  Created by Maharjan Binish on 2023/04/30.
//

import SwiftUI

extension ButtonStyle where Self == PrimaryButtonStyle {
    /// 塗りつぶし背景のボタンスタイル。
    public static var primary: PrimaryButtonStyle {
        PrimaryButtonStyle()
    }
}

/// 塗りつぶし背景のボタンスタイル。
///
/// 実際に利用する際は、`ButtonStyle`で拡張されている`primary`静的プロパティを指定する。
/// ```swift
///  Button("...") {
///     // ...
///  }
///  .buttonStyle(.primary)
/// ```
public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.app(.white1))
            .font(.app(.title3))
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor(isPressed: configuration.isPressed))
                    .animation(nil, value: configuration.isPressed)
            }
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        if !isEnabled {
            return .app(.gray1)
        }
        return .app(isPressed ? .blue1 : .primary)
    }
}
