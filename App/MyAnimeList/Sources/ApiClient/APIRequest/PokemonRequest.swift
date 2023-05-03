//
//  Created by Maharjan Binish on 2023/04/08.
//

import Foundation

public struct PokemonRequest: Request {
    public init(offset: Int, limit: Int) {
        self.offset = offset
        self.limit = limit
    }
    public typealias Success = PokemonList

    public var method: HTTPMethod { .get }
    public var path: String { "/pokemon" }

    public var offset: Int
    public var limit: Int

    public var queryParameters: QueryParameters? {
        [
            "offset": .string(String(offset)),
            "limit": .string(String(limit)),
        ]
    }
}
