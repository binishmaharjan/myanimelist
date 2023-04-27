//
//  Created by Maharjan Binish on 2023/04/27.
//

import SwiftUI
import AppFeature

public protocol App: SwiftUI.App {
    var appDelegate: AppDelegate { get }
}

extension App {
    public var body: some Scene {
        WindowGroup {
            RootView(
                store: appDelegate.store.scope(
                    state: \.rootState,
                    action: AppDelegateReducer.Action.rootAction
                )
            )
        }
    }
}
