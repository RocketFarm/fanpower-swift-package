//
//  File.swift
//  
//
//  Created by Christopher Wyatt on 4/5/23.
//

import Foundation
import UIKit

public class ScrollableFanPowerView: UIView {
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet var contentView: FPScrollView!
    @IBOutlet weak var fanPowerView: FanPowerView!
    
    public func setup(heightConstant: CGFloat, topMarginConstant: CGFloat, bottomMarginConstant: CGFloat, tokenForJwtRequest: String, publisherToken: String, publisherId: String, shareUrl: String, allowPhoneRegistration: Bool = true, referenceFrame: CGRect?, completionHandler: @escaping () -> Void) {
        initSubviews()
        
        viewHeight.constant = heightConstant
        topMargin.constant = topMarginConstant
        bottomMargin.constant = bottomMarginConstant
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { //TODO: proper race condition fix
            self.fanPowerView.setup(tokenForJwtRequest: tokenForJwtRequest,
                                    publisherToken: publisherToken,
                                    publisherId: publisherId,
                                    shareUrl: shareUrl,
                                    allowPhoneRegistration: allowPhoneRegistration,
                                    completionHandler: completionHandler)
        }
        
        if let referenceFrame = referenceFrame {
            contentView.frame = referenceFrame
        } else if let windowFrame = window?.frame {
            contentView.frame = windowFrame
        }
    }
    
    public func setup(heightConstant: CGFloat, topMarginConstant: CGFloat, bottomMarginConstant: CGFloat, tokenForJwtRequest: String, publisherToken: String, publisherId: String, shareUrl: String, referenceFrame: CGRect?, allowPhoneRegistration: Bool = true, propIds: [String], completionHandler: @escaping () -> Void) {
        initSubviews()
        
        viewHeight.constant = heightConstant
        topMargin.constant = topMarginConstant
        bottomMargin.constant = bottomMarginConstant
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { //TODO: proper race condition fix
            self.fanPowerView.setup(tokenForJwtRequest: tokenForJwtRequest,
                                    publisherToken: publisherToken,
                                    publisherId: publisherId,
                                    shareUrl: shareUrl,
                                    allowPhoneRegistration: allowPhoneRegistration,
                                    propIds: propIds,
                                    completionHandler: completionHandler)
        }
        
        if let referenceFrame = referenceFrame {
            contentView.frame = referenceFrame
        } else if let windowFrame = window?.frame {
            contentView.frame = windowFrame
        }
    }
    
    public func setContentOffset(offset: CGPoint) {
        if let contentView = contentView {
            var fanPowerOffset = contentView.contentOffset
            fanPowerOffset.y = offset.y
            contentView.setContentOffset(fanPowerOffset, animated: false)
        }
    }
    
    public func setCollectionViewLayout() {
        fanPowerView.setCollectionViewLayout()
    }
    
    private func initSubviews() {
        let bundle = Bundle(for: ScrollableFanPowerView.self).path(forResource: "FanpowerPackage", ofType: "bundle")
        if let bundle = bundle {
            let nib = UINib(nibName: "ScrollableFanPowerView", bundle: Bundle(path: bundle))
            nib.instantiate(withOwner: self, options: nil)
        } else {
            let nib = UINib(nibName: "ScrollableFanPowerView", bundle: Bundle.module)
            nib.instantiate(withOwner: self, options: nil)
        }
        
        addSubview(contentView)
    }
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if contentView == nil {
            return view
        }
        return view == contentView || view == fanPowerView.contentView ? nil : view
    }
}

class FPScrollView: UIScrollView {
}
