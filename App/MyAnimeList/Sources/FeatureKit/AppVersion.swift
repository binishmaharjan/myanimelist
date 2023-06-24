//
//  Created by Maharjan Binish on 2023/04/30.
//

import Foundation
import Dependencies

public struct AppVersion: SemanticVersion {
    public init(major: UInt, minor: UInt, patch: UInt) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public var major: UInt
    public var minor: UInt
    public var patch: UInt

    public static var current: AppVersion {
        let rawValue = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return AppVersion(rawValue: rawValue)!
    }
}

// MARK: DependencyValues
extension DependencyValues {
    public var appVersion: AppVersion {
        get { self[AppVersion.self] }
        set { self[AppVersion.self] = newValue }
    }
}

// MARK: Dependency(Test and Live Value)
extension AppVersion: DependencyKey {
    public static let liveValue = Self.current
    public static let testValue = Self(major: 1, minor: 0, patch: 0)
    public static let previewValue = Self(major: 1, minor: 0, patch: 0)
}


