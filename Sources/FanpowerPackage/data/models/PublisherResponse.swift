//
//  JwtResponse.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/1/23.
//

import Foundation
struct PublisherResponse: Decodable, Encodable, Equatable {
    let picker_logo_url: String
    let primary_color: String?
    let secondary_color: String?
    let icon_color: String?
    let text_link_color: String?
    let background_color: String?
    let settings: Settings?
}

struct Settings: Decodable, Encodable, Equatable {
    let require_terms_checkbox: String?
    let require_terms_content: String?
}
