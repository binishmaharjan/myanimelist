//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation

public enum APIClientError: Error, Hashable {
    case request(RequestError)
    case urlSession(URLError)
    case unknown(NSError)
}
