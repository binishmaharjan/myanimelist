//
//  Created by Maharjan Binish on 2023/04/27.
//

import AppUI
import ComposableArchitecture
import SwiftUI

public struct RootView: View {
    public init(store: StoreOf<Root>) {
        self.store = store
    }

    private let store: StoreOf<Root>

    public var body: some View {
        SwitchStore(store.scope(state: \.phase, action: Root.Action.phase)) {
            CaseLet(state: /Root.State.Phase.launch, action: Root.Action.Phase.launch) { store in
                LaunchView(store: store)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static let store: StoreOf<Root> = .init(initialState: .init(), reducer: Root())
    static var previews: some View {
        Group {
            RootView(store: store)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")
        }
    }
}
