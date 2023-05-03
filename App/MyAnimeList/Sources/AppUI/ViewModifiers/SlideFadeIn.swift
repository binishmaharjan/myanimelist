//
//  Created by Maharjan Binish on 2023/05/03.
//

import SwiftUI

struct SlideFadeIn: ViewModifier {
    var show: Bool
    var offset: Double

    func body(content: Content) -> some View {
        content
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : offset)
    }
}

extension View {
    public func slideFadeIn(show: Bool, offset: Double = 10) -> some View {
        self.modifier(SlideFadeIn(show: show, offset: offset))
    }
}
