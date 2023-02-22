//
//  PropResponse.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/1/23.
//

import Foundation

struct PropResponse: Decodable, Encodable, Equatable {
    let proposition: String
    let picks: [Pick]
}
