//
//  Created by Maharjan Binish on 2023/05/02.
//

import Foundation

public struct User: JSONResponseValue, Equatable {
    public init(id: String, username: String, firstName: String, lastName: String) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
    }

    public var id: String
    public var username: String
    public var firstName: String
    public var lastName: String
}
