import Foundation
import UIKit

public struct FanpowerPackage {
    public static func registerFonts() {
        registerFont(bundle: .module, fontName: "Outfit-VariableFont_wght", fontExtension: "ttf")
    }
    fileprivate static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {
        guard let fontUrl = bundle.url(forResource: fontName, withExtension: fontExtension),
              let fontDataProvider = CGDataProvider(url: fontUrl as CFURL),
              let font = CGFont(fontDataProvider) else {
            fatalError("Couldn't create font \(fontName).\(fontExtension)")
        }
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
    }
}
