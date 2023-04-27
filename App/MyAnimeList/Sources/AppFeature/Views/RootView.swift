//
//  Created by Maharjan Binish on 2023/04/27.
//

import ComposableArchitecture
import SwiftUI

public struct RootView: View {
    public init(store: StoreOf<Root>) {
        self.store = store
    }

    private let store: StoreOf<Root>

    public var body: some View {
        Text("Root View")
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(
            store: .init(
                initialState: .init(),
                reducer: Root()
            )
        )
    }
}
