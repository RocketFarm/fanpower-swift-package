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
    
    public func setup(heightConstant: CGFloat, topMarginConstant: CGFloat, bottomMarginConstant: CGFloat, tokenForJwtRequest: String, publisherToken: String, publisherId: String, shareUrl: String, completionHandler: @escaping () -> Void) {
        initSubviews()
        
        viewHeight.constant = heightConstant
        topMargin.constant = topMarginConstant
        bottomMargin.constant = bottomMarginConstant
        
        fanPowerView.setup(tokenForJwtRequest: tokenForJwtRequest, publisherToken: publisherToken, publisherId: publisherId, shareUrl: shareUrl, completionHandler: completionHandler)
    }
    
    public func setContentOffset(offset: CGPoint) {
        var fanPowerOffset = contentView.contentOffset
        fanPowerOffset.y = offset.y
        contentView.setContentOffset(fanPowerOffset, animated: false)
    }
    
    public func setCollectionViewLayout() {
        fanPowerView.setCollectionViewLayout()
    }
    
    private func initSubviews() {
        let nib = UINib(nibName: "ScrollableFanPowerView", bundle: Bundle.module)
        nib.instantiate(withOwner: self, options: nil)
        
        addSubview(contentView)
    }
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == contentView ? nil : view
    }
}

class FPScrollView: UIScrollView {
}
