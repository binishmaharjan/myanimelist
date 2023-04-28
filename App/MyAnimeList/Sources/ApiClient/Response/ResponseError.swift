//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation

public enum ResponseError: Error, Hashable {
    case api(APIError)
    case decoding(NSError)

    public var apiError: APIError? {
        switch self {
        case .api(let apiError):
            return apiError

        case .decoding:
            return nil
        }
    }
}
