//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation

/// - note: 生成コストが高いため、キャッシュしておく。
private let apiDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSTIX")
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.timeZone = TimeZone(abbreviation: "JST")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

extension JSONDecoder.DateDecodingStrategy {
    public static var api: Self {
        .formatted(apiDateFormatter)
    }
}

extension JSONEncoder.DateEncodingStrategy {
    public static var api: Self {
        .formatted(apiDateFormatter)
    }
}
