//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation
public struct QueryParameters {
    public let percentEncodedURLQueryItems: [URLQueryItem]

    public var isEmpty: Bool {
        percentEncodedURLQueryItems.isEmpty
    }

    public typealias Key = String
    public enum Value {
        case string(String?)
        case array(Array<String>?)
    }
}

extension QueryParameters: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(
            percentEncodedURLQueryItems: elements.flatMap(Self.makePercentEncodedQueryItems(element:))
        )
    }

    public init(_ queries: [String: String]) {
        self.init(
            percentEncodedURLQueryItems: queries.flatMap {
                Self.makePercentEncodedQueryItems(element: ($0, .string($1)))
            }
        )
    }

    private static func makePercentEncodedQueryItems(element: (key: Key, value: Value)) -> [URLQueryItem] {
        switch element.value {
        case .string(let string?):
            return [
                URLQueryItem(
                    name: element.key.addingPercentEncoding(withAllowedCharacters: .rfc3986URLQueryAllowed) ?? element.key,
                    value: string.addingPercentEncoding(withAllowedCharacters: .rfc3986URLQueryAllowed) ?? string
                )
            ]
        case .array(let array?):
            return array.map {
                URLQueryItem(
                    name: element.key.addingPercentEncoding(withAllowedCharacters: .rfc3986URLQueryAllowed) ?? element.key,
                    value: $0.addingPercentEncoding(withAllowedCharacters: .rfc3986URLQueryAllowed) ?? $0
                )
            }
        case .string(.none), .array(.none):
            return []
        }
    }
}

extension QueryParameters.Value: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension QueryParameters.Value: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: String...) {
        self = .array(elements)
    }
}
