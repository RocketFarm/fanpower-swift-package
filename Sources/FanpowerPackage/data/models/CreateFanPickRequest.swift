//
//  CreateFanPickRequest.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/6/23.
//

import Foundation

struct CreateFanPickRequest: Encodable, Equatable {
    let pick_id: String
    let prop_id: String
    let source_url: String = "iOS App"
    let publisher_id: String
    let fan_id: String? = nil
    let proposition: Proposition
    let ip_address: String
    let fanCity: String
    let fanState: String
    let fanCountry: String
    let fanZipCode: String
    let fanGeoLocation: String
    let fanTimeZone: String
    let version: String = "2.4.1"
}

struct Proposition: Encodable, Equatable {
    let id: String
}
