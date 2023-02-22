//
//  FanPicksResponse.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/12/23.
//

import Foundation


struct FanPicksResponse: Decodable, Encodable, Equatable {
    let pick_id: Int
    let prop_id: Int
}
