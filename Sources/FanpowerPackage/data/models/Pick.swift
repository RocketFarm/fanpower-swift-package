//
//  Pick.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/1/23.
//

import Foundation

struct Pick: Decodable, Encodable, Equatable {
    let id: String
    let display_title: String
    let pick_popularity: Float
}
