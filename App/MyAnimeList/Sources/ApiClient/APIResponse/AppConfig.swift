//
//  Created by Maharjan Binish on 2023/04/15.
//

import Foundation

public struct AppConfig: JSONResponseValue {
    public init(iOS: String) {
        self.iOS = iOS
    }

    public var iOS: String
}

public struct AppInfo: JSONResponseValue {
    public init(termsUpdatedAt: Date) {
        self.termsUpdatedAt = termsUpdatedAt
    }

    public var termsUpdatedAt: Date
}
