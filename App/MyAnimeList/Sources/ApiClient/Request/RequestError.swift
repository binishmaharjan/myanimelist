//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation

public enum RequestError: Error, Hashable {
    case invalidEndpoint(URL)
    case requestBodyEncodingFailed(NSError)
}
