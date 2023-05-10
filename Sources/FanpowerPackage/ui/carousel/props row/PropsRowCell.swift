//
//  PropsRowCellTableViewCell.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/1/23.
//

import UIKit

class PropsRowCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var progressBarWidth: NSLayoutConstraint!
    @IBOutlet weak var labelsHolder: UIView!
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var subLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        labelsHolder.layer.borderWidth = 1
        labelsHolder.layer.cornerRadius = 23
        
        progressBarView.layer.borderWidth = 1
        progressBarView.layer.borderColor = Constants.white.cgColor
        progressBarView.layer.cornerRadius = 23
        progressBarView.backgroundColor = Constants.progressYellow
        progressBarView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        progressBarView.clipsToBounds = true
        
        if FanpowerApi.shared.publisherId == "367" {
            styleForNascar()
        }
    }
    
    private func styleForNascar() {
        Constants.convertNascarLabel(label: mainLabel)
        Constants.convertNascarLabel(label: subLabel)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
