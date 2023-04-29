//
//  Created by Maharjan Binish on 2023/04/30.
//

import Foundation

public protocol SemanticVersion: Hashable, Comparable {
    init(major: UInt, minor: UInt, patch: UInt)
    var major: UInt { get }
    var minor: UInt { get }
    var patch: UInt { get }
}

extension SemanticVersion {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        let lhsComparators = [lhs.major, lhs.minor, lhs.patch]
        let rhsComparators = [rhs.major, rhs.minor, rhs.patch]
        return lhsComparators.lexicographicallyPrecedes(rhsComparators)
    }
}

public extension SemanticVersion {
    var rawValue: String {
        [major, minor, patch].map(String.init(_:)).joined(separator: ".")
    }

    init?(rawValue: String) {
        let splitValue = rawValue.split(separator: ".").compactMap { UInt($0) }
        guard splitValue.count == 3 else {
            return nil
        }
        self.init(major: splitValue[0], minor: splitValue[1], patch: splitValue[2])
    }
}
