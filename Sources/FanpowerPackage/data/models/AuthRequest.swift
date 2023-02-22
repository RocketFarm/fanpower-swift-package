//
//  AuthRequest.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/4/23.
//

import Foundation

struct AuthRequest: Decodable, Encodable, Equatable {
    let email: String?
    let phoneNumber: String?
}
