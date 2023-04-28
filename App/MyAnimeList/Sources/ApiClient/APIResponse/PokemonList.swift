//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation

public struct PokemonList: JSONResponseValue {
    public init(count: Int, next: String, previous: String? = nil, results: [Pokemon]) {
        self.count = count
        self.next = next
        self.previous = previous
        self.results = results
    }

    public var count: Int
    public var next: String
    public var previous: String?
    public var results: [Pokemon]
}

public struct Pokemon: JSONResponseValue {
    public init(name: String, url: String) {
        self.name = name
        self.url = url
    }

    public var name: String
    public var url: String
}
