//
//  Created by Maharjan Binish on 2023/04/30.
//

import Foundation
import Dependencies

public struct UserDefaultsClient {
    public var termsOfUseAgreedDate: () -> Date?
    public var setTermsOfUseAgreedDate: (Date) -> Void
}

// MARK: Dependency
extension DependencyValues {
    public var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

// MARK: Dependency(Test Value)
extension UserDefaultsClient: TestDependencyKey {
    public static let testValue = Self(
        termsOfUseAgreedDate: unimplemented(),
        setTermsOfUseAgreedDate: unimplemented()
    )
}

// MARK: Dependency(Live Value)
private enum Keys {
    static let termsOfUseUpdateDate = "termsOfUseAgreedDate"
}

extension UserDefaultsClient: DependencyKey {
    public static let liveValue = Self.live(userDefaults: .standard)
}

extension UserDefaultsClient {
    public static func live(userDefaults: UserDefaults) -> Self {
        Self(
            termsOfUseAgreedDate: {
                userDefaults.object(forKey: Keys.termsOfUseUpdateDate) as? Date
            },
            setTermsOfUseAgreedDate: {
                userDefaults.set($0, forKey: Keys.termsOfUseUpdateDate)
            }
        )
    }
}
