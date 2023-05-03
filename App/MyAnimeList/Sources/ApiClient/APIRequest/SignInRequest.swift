//
//  Created by Maharjan Binish on 2023/05/02.
//

import Foundation

public struct SignInRequest: Request, Equatable {
    public typealias Success = User

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    public var method: HTTPMethod { .get }
    public var path: String { "/login" }

    public var username: String
    public var password: String

    public var body: RequestBody? {
        JSONRequestBody {
            [
                "username": username,
                "password": password
            ]
        }
    }

    /*
     struct Parameter: Encodable {
         var username: String
         var password: String
     }

     public var body: RequestBody? {
         EncodableJSONRequestBody(value: parameters)
     }
     */
}
