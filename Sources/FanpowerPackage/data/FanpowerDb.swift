//
//  FanpowerDb.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/12/23.
//

import Foundation
import UIKit

class FanpowerDb {
    static let shared = FanpowerDb()
    let preferences = UserDefaults.standard
    let keyUserId = "keyUserId"
    
    private init() { }
    
    func isLoggedIn() -> Bool {
        return getUserId() != nil
    }
    
    func logOut() {
        preferences.set(nil, forKey: keyUserId)
    }
    
    func setUserId(userId: String?) {
        preferences.set(userId, forKey: keyUserId)
    }
    
    func getUserId() -> String? {
        return preferences.string(forKey: keyUserId)
    }
}

public class FanPower {
    public static func logout() {
        FanpowerDb.shared.logOut()
    }
}
