//
//  Created by Maharjan Binish on 2023/04/29.
//

import AppUI
import ComposableArchitecture
import SwiftUI

struct LaunchView: View {
    struct ViewState: Equatable {
        init(state: Launch.State) { }
    }
    var store: StoreOf<Launch>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            Asset.Images.imgMalLogo.swiftUIImage
                .ignoresSafeArea()
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .alert(
                    store: self.store.scope(
                        state: \.$destination, action: Launch.Action.destination
                    ),
                    state: /Launch.Destination.State.alert,
                    action: Launch.Destination.Action.alert
                )
        }
    }
}

internal struct LaunchView_Previews: PreviewProvider {
    static let store: StoreOf<Launch> = .init(initialState: .init(), reducer: Launch())
    static var previews: some View {
        Group {
            LaunchView(store: store)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
                .previewDisplayName("iPhone 14")

            LaunchView(store: store)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                .previewDisplayName("iPhone 14 Pro Max")
                .preferredColorScheme(.dark)

            LaunchView(store: store)
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .previewDisplayName("iPhone 8")
        }
    }
}
