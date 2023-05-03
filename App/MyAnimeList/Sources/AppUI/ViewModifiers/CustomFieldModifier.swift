//
//  Created by Maharjan Binish on 2023/05/03.
//

import SwiftUI

struct TextFieldModifier: ViewModifier {
    var icon: String

    func body(content: Content) -> some View {
        content
            .overlay(
                HStack {
                    Image(systemName: icon)
                        .frame(width: 36, height: 36)
                        .background(.thinMaterial)
                        .cornerRadius(14)
                        .outlineOverlay(cornerRadius: 14)
                        .offset(x: -46)
                        .foregroundStyle(.secondary)
                        .accessibility(hidden: true)
                    Spacer()
                }
            )
            .foregroundStyle(.primary)
            .padding(15)
            .padding(.leading, 40)
            .background(.thinMaterial)
            .cornerRadius(20)
            .outlineOverlay(cornerRadius: 20)
    }
}

extension View {
    public func customField(icon: String) -> some View {
        self.modifier(TextFieldModifier(icon: icon))
    }
}
