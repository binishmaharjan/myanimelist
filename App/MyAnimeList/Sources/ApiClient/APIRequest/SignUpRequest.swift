//
//  Created by Maharjan Binish on 2023/05/03.
//

import Foundation

public struct SignUpRequest: Request, Equatable {
    public typealias Success = User

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    public var method: HTTPMethod { .get }
    public var path: String { "/signup" }

    public var username: String
    public var password: String

    /*
    public var body: RequestBody? {
        JSONRequestBody {
            [
                "username": username,
                "password": password
            ]
        }
    }
     */

     struct Parameter: JSONEncodable {
         var username: String
         var password: String
     }

     public var body: RequestBody? {
         let parameters = Parameter(username: username, password: password)
         return EncodableJSONRequestBody(value: parameters)
     }
}
