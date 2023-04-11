//
//  CreateFanPickResponse.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/6/23.
//

import Foundation

struct CreateFanPickResponse: Decodable, Encodable, Equatable {
    let fanPick: String
    let picks: [Pick]
}
