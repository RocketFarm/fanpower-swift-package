//
//  IpResponse.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/6/23.
//

import Foundation

struct IpResponse: Decodable, Encodable, Equatable {
    let fanState: String
    let fanCountry: String
    let fanCity: String
    let ipAddress: String
    let fanZipCode: String
    let fanGeoLocation: String
    let fanTimeZone: String
}
