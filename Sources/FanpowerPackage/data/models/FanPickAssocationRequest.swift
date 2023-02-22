//
//  FanPickAssocationRequest.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/6/23.
//

import Foundation

struct FanPickAssocationRequest: Encodable, Equatable {
    let token: String
    let fan_pick_id: String
    let fan_id: String
    let prop_id: String
    let ad_zone_id: String
}
