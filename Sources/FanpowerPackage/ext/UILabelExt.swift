//
//  UILabelExt.swift
//  FanpowerPackage
//
//  Created by Christopher Wyatt on 5/31/23.
//

import Foundation

extension UILabel {
  func set(html: String) {
    if let htmlData = html.data(using: .unicode) {
      do {
        self.attributedText = try NSAttributedString(data: htmlData,
                                                     options: [.documentType: NSAttributedString.DocumentType.html],
                                                     documentAttributes: nil)
      } catch let e as NSError {
        print("Couldn't parse \(html): \(e.localizedDescription)")
      }
    }
  }
}
