//
//  HKCell.swift
//  TableView
//
//  Created by 罗伟 on 2017/5/15.
//  Copyright © 2017年 罗伟. All rights reserved.
//

import UIKit

class HKCell: UITableViewCell {
    @IBOutlet weak var bgImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateBgImageViewFrame() {
        let toWindowFrame = self.convert(self.bounds, to: self.window)
        let superViewCenter = self.superview!.center
        
        let cellOffSetY = toWindowFrame.midY - superViewCenter.y
        let ratio = cellOffSetY/self.superview!.frame.height
        let offSetY = -self.frame.height * ratio
        let transY = CGAffineTransform(translationX: 0, y: offSetY)
        
        self.bgImageView.transform = transY
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
