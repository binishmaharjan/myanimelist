//
//  Created by Maharjan Binish on 2023/04/27.
//

import ComposableArchitecture
import UIKit
import AppFeature

public final class AppDelegate: NSObject, UIApplicationDelegate {
    private var _store: StoreOf<AppDelegateReducer>?

    var store: StoreOf<AppDelegateReducer> {
        if let _store {
            return _store
        }
        let store = Store(initialState: AppDelegateReducer.State(), reducer: AppDelegateReducer())
        self._store = store
        return store
    }

    private(set) lazy var viewStore = ViewStore(store, observe: { $0 })

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        return true
    }
}

struct AppDelegateReducer: Reducer {
    struct State: Equatable {
        var rootState = Root.State()
    }

    enum Action {
        case didFinishLaunching
        case rootAction(Root.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .didFinishLaunching:
                break
            case .rootAction(_):
                break
            }
            return .none
        }

        Scope(state: \.rootState, action: /Action.rootAction) {
            Root()
        }
    }
}
