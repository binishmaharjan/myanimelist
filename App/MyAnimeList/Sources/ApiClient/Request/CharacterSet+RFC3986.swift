//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation

// https://github.com/Alamofire/Alamofire/blob/f82c23a8a7ef8dc1a49a8bfc6a96883e79121864/Source/URLEncodedFormEncoder.swift#L964-L982
extension CharacterSet {
    static let rfc3986URLQueryAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodeDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return .urlQueryAllowed.subtracting(encodeDelimiters)
    }()
}

