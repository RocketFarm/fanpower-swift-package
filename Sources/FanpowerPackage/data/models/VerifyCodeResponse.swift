//
//  VerifyCodeResponse.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/6/23.
//

import Foundation

struct VerifyCodeResponse: Decodable, Encodable, Equatable {
    let id: String?
    let message: String?
}
