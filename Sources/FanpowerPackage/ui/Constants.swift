//
//  Constants.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/4/23.
//

import Foundation
import UIKit

class Constants {
    static let headerBgColor = UIColor(#colorLiteral(red: 0.1176470444, green: 0.1176470444, blue: 0.1176470444, alpha: 1))
    static let black = UIColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    static let progressYellow = UIColor(#colorLiteral(red: 0.9995649457, green: 0.9797231555, blue: 0.8977681994, alpha: 1))
    static let white = UIColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    static let splashGradientYellow = UIColor(#colorLiteral(red: 0.897775352, green: 0.7267916799, blue: 0.01537941117, alpha: 1))
    static let pickedBorderYellow = UIColor(#colorLiteral(red: 0.9995651841, green: 0.8042533994, blue: 0, alpha: 1))
    static let splashGradientClear = UIColor(#colorLiteral(red: 0.897775352, green: 0.7267916799, blue: 0.01537941117, alpha: 0))
    static let errorRed = UIColor(#colorLiteral(red: 0.8937767148, green: 0.006564801093, blue: 0.1700305045, alpha: 1))
    static let notChosenBackground = UIColor(#colorLiteral(red: 0.9647058845, green: 0.9647058845, blue: 0.9647058845, alpha: 1))
    static let notChosen = UIColor(#colorLiteral(red: 0.6435206532, green: 0.6187660098, blue: 0.6707072854, alpha: 1))
    
    static func getAddress(for network: Network) -> String? {
        var address: String?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == network.rawValue {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }
    
    static func convertNascarField(field: UITextField) {
        if let font = field.font {
            field.font = convertNascarFont(font: font)
        } else {
            print("Could not convert field font!")
        }
    }
    
    static func convertNascarLabel(label: UILabel) {
        label.font = convertNascarFont(font: label.font)
    }
    
    static func convertNascarFont(font: UIFont) -> UIFont {
        if font.fontName == "Outfit-Regular" {
            return UIFont(name: "Stainless-Regular", size: font.pointSize)!
        } else if font.fontName == "Outfit-ExtraBold" {
            return UIFont(name: "Stainless-Black", size: font.pointSize)!
        } else if font.fontName == "Outfit-Bold" {
            return UIFont(name: "Stainless-Bold", size: font.pointSize)!
        }
        print("Could not convert font \(font.fontName)")
        return font
    }
    
    enum Network: String {
        case wifi = "en0"
        case cellular = "pdp_ip0"
    }
}
