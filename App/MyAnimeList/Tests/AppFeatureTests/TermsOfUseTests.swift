//
//  Created by Maharjan Binish on 2023/06/26.
//

import XCTest
import ComposableArchitecture

@testable import AppFeature

@MainActor
final class TermsOfUseTests: XCTestCase {

    func test_OnAgreedButtonTapped_ShowLogin() async {
        let expectation = expectation(description: "Save date in user defaults")
        let store = TestStore(initialState: TermsOfUse.State(latestUpdateDate: .distantFuture), reducer: TermsOfUse()) {
            $0.userDefaultsClient.setTermsOfUseAgreedDate = { _ in
                expectation.fulfill()
            }
        }

        await store.send(.agreedButtonTapped)
        wait(for: [expectation], timeout: 0)
//        await fulfillment(of: [expectation], timeout: 0)
        await store.receive(.delegate(.showLogin))
    }
}
