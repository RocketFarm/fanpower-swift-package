//
//  FanProfile.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/4/23.
//

import Foundation

struct FanProfile: Decodable, Encodable, Equatable {
    let username: String
    let otp_secret_key: String
    let persistence_token: String
    let id: String
}
