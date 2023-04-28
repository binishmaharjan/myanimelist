//
//  Created by Maharjan Binish on 2023/04/29.
//

import AppUI
import ComposableArchitecture
import SwiftUI

internal struct LaunchView: View {
    var store: StoreOf<Launch>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Asset.Images.imgMalLogo.swiftUIImage
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(Asset.Colors.background.swiftUIColor)
            .onAppear {
                viewStore.send(.onAppear)
            }
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
