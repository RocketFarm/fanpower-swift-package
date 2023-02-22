//
//  ReferralCodeResponse.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/18/23.
//

import Foundation

struct ReferralCodeResponse: Decodable, Encodable, Equatable {
    let referral_url: String?
}
