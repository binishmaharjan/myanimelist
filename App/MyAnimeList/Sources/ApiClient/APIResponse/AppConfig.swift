//
//  Created by Maharjan Binish on 2023/04/15.
//

import Foundation

public struct AppConfig: JSONResponseValue, Equatable {
    public init(iOSVersion : String) {
        self.iOSVersion = iOSVersion
    }

    public var iOSVersion : String
}

public struct AppInfo: JSONResponseValue {
    public init(termsUpdatedAt: Date) {
        self.termsUpdatedAt = termsUpdatedAt
    }

    public var termsUpdatedAt: Date
}
