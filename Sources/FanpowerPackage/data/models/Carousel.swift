//
//  Carousel.swift
//  
//
//  Created by Christopher Wyatt on 3/14/23.
//

import Foundation

struct Carousel: Decodable, Encodable, Equatable {
    let prop_ids: [PropId]
}

struct PropId: Decodable, Encodable, Equatable {
    let prop_id: Int
}
