//
//  Created by Maharjan Binish on 2023/06/23.
//

import XCTest
import ComposableArchitecture
import APIClient
@testable import AppFeature

@MainActor
final class LaunchTests: XCTestCase {

    private let testHTTPURLResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    private let testError = ResponseError.api(APIError(status: 400, code: .notFound, message: "Not Found"))
    private let testClock = TestClock()
    private let immediateClock = ImmediateClock()

    func test_OnAppear_FetchAppVersion() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppConfig  = {
                .init(result: .failure(self.testError), urlResponse: self.testHTTPURLResponse)
            }
        }

        await store.send(.onAppear)
        await store.receive(.fetchRequiredAppVersion)
        await store.receive(.requiredAppVersionResponse(.failure(testError))) {
            $0.destination = .alert(.appVersionErrorAlert())
        }
    }

    func test_OnAppear_FetchAppVersion_ExhaustivityOff() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppConfig = {
                .init(result: .failure(self.testError), urlResponse: self.testHTTPURLResponse)
            }
        }
        store.exhaustivity = .off

        await store.send(.onAppear)
        await store.receive(.fetchRequiredAppVersion)
    }

    func test_FetchAppVersion_Failure_ShowAlert() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppConfig = {
                .init(result: .failure(self.testError), urlResponse: self.testHTTPURLResponse)
            }
        }

        await store.send(.fetchRequiredAppVersion)
        await store.receive(.requiredAppVersionResponse(.failure(testError))) {
            $0.destination = .alert(.appVersionErrorAlert())
        }
    }

    func test_FetchAppVersion_Failure_ShowAlert_Retry() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppConfig = {
                .init(result: .failure(self.testError), urlResponse: self.testHTTPURLResponse)
            }
        }

        await store.send(.fetchRequiredAppVersion)
        await store.receive(.requiredAppVersionResponse(.failure(testError))) {
            $0.destination = .alert(.appVersionErrorAlert())
        }
        await store.send(.destination(.presented(.alert(.retry(.appVersion))))) {
            $0.destination = nil
        }

        await store.receive(.fetchRequiredAppVersion)
        await store.receive(.requiredAppVersionResponse(.failure(testError))) {
            $0.destination = .alert(.appVersionErrorAlert())
        }
    }

    func test_FetchAppVersion_Failure_ShowAlert_Retry_ExhaustivityOff() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppConfig = {
                .init(result: .failure(self.testError), urlResponse: self.testHTTPURLResponse)
            }
        }
        store.exhaustivity = .off

        await store.send(.fetchRequiredAppVersion)
        await store.receive(.requiredAppVersionResponse(.failure(testError))) {
            $0.destination = .alert(.appVersionErrorAlert())
        }
        await store.send(.destination(.presented(.alert(.retry(.appVersion))))) {
            $0.destination = nil
        }
    }

    func test_FetchAppVersion_Success_HasNoNewVersion_FetchAppInfo() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppConfig = {
                .init(result: .success(AppConfig(iOSVersion: "1.0.0")), urlResponse: self.testHTTPURLResponse)
            }
            $0.apiClient.fetchAppInfo = {
                .init(result: .failure(self.testError), urlResponse: self.testHTTPURLResponse)
            }
        }

        await store.send(.fetchRequiredAppVersion)
        await store.receive(.requiredAppVersionResponse(.success(AppConfig(iOSVersion: "1.0.0"))))
        await store.receive(.fetchAppInfo)
        await store.receive(.appInfoResponse(.failure(testError))) {
            $0.destination = .alert(.appInfoErrorAlert())
        }
    }

    func test_FetchAppVersion_Success_HasNoNewVersion_FetchAppInfo_ExhaustivityOff() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppConfig = {
                .init(result: .success(AppConfig(iOSVersion: "1.0.0")), urlResponse: self.testHTTPURLResponse)
            }
            $0.apiClient.fetchAppInfo = {
                .init(result: .failure(self.testError), urlResponse: self.testHTTPURLResponse)
            }
        }
        store.exhaustivity = .off

        await store.send(.fetchRequiredAppVersion)
        await store.receive(.requiredAppVersionResponse(.success(AppConfig(iOSVersion: "1.0.0"))))
        await store.receive(.fetchAppInfo)
    }

    func test_FetchAppVersion_Success_HasNewVersion_ShowForceUpdate() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppConfig = {
                .init(result: .success(AppConfig(iOSVersion: "1.0.1")), urlResponse: self.testHTTPURLResponse)
            }
        }

        await store.send(.fetchRequiredAppVersion)
        await store.receive(.requiredAppVersionResponse(.success(AppConfig(iOSVersion: "1.0.1")))) {
            $0.destination = .alert(.forceUpdateAlert())
        }
    }

    func test_FetchAppVersion_Success_HasNewVersion_ShowForceUpdate_OpenURL() async {
        let expectation = expectation(description: "openURL was executed.")
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppConfig = {
                .init(result: .success(AppConfig(iOSVersion: "1.0.1")), urlResponse: self.testHTTPURLResponse)
            }
            $0.openURL = OpenURLEffect() { _ in
                expectation.fulfill()
                return true
            }
        }

        await store.send(.fetchRequiredAppVersion)
        await store.receive(.requiredAppVersionResponse(.success(AppConfig(iOSVersion: "1.0.1")))) {
            $0.destination = .alert(.forceUpdateAlert())
        }

        await store.send(.destination(.presented(.alert(.forceUpdate))))
        await store.receive(.openForceUpdateURL)
        await fulfillment(of: [expectation], timeout: 0)
    }

    func test_FetchAppConfig_Failure_ShowAlert() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppInfo = {
                .init(result: .failure(self.testError), urlResponse: self.testHTTPURLResponse)
            }
        }

        await store.send(.fetchAppInfo)
        await store.receive(.appInfoResponse(.failure(testError))) {
            $0.destination = .alert(.appInfoErrorAlert())
        }
    }

    func test_FetchAppConfig_Failure_ShowAlert_Retry() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppInfo = {
                .init(result: .failure(self.testError), urlResponse: self.testHTTPURLResponse)
            }
        }

        await store.send(.fetchAppInfo)
        await store.receive(.appInfoResponse(.failure(testError))) {
            $0.destination = .alert(.appInfoErrorAlert())
        }

        await store.send(.destination(.presented(.alert(.retry(.appInfo))))) {
            $0.destination = nil
        }

        await store.receive(.fetchAppInfo)
        await store.receive(.appInfoResponse(.failure(testError))) {
            $0.destination = .alert(.appInfoErrorAlert())
        }
    }

    func test_FetchAppConfig_Failure_ShowAlert_Retry_ExhaustivityOff() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppInfo = {
                .init(result: .failure(self.testError), urlResponse: self.testHTTPURLResponse)
            }
        }
        store.exhaustivity = .off

        await store.send(.fetchAppInfo)
        await store.receive(.appInfoResponse(.failure(testError))) {
            $0.destination = .alert(.appInfoErrorAlert())
        }

        await store.send(.destination(.presented(.alert(.retry(.appInfo))))) {
            $0.destination = nil
        }

        await store.receive(.fetchAppInfo)
    }

    func test_FetchAppConfig_Success_TermsNotAgreed_ShowTerms() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppInfo = {
                .init(result: .success(AppInfo(termsUpdatedAt: .distantFuture)), urlResponse: self.testHTTPURLResponse)
            }
            $0.userDefaultsClient.termsOfUseAgreedDate = {
                Date.distantPast
            }
        }

        await store.send(.fetchAppInfo)
        await store.receive(.appInfoResponse(.success(AppInfo(termsUpdatedAt: .distantFuture))))
        await store.receive(.delegate(.needsTermsOfUseAgreement(latestUpdateDate: .distantFuture)))
    }

    func test_FetchAppConfig_Success_TermsAgreed_ShowLogin() async {
        let store = TestStore(initialState: Launch.State(), reducer: Launch()) {
            $0.continuousClock = immediateClock
            $0.apiClient.fetchAppInfo = {
                .init(result: .success(AppInfo(termsUpdatedAt: .distantFuture)), urlResponse: self.testHTTPURLResponse)
            }
            $0.userDefaultsClient.termsOfUseAgreedDate = {
                Date.distantFuture
            }
        }

        await store.send(.fetchAppInfo)
        await store.receive(.appInfoResponse(.success(AppInfo(termsUpdatedAt: .distantFuture))))
        await store.receive(.delegate(.showLogin))
    }
}



