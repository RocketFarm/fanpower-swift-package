//
//  File.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/6/23.
//

import Foundation

struct VerifyCodeRequest: Encodable, Equatable {
    let code: String
    let phoneNumber: String?
    let email: String?
    let username: String? = nil
}
