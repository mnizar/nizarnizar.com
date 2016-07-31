//
//  BlogTableViewCell.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 4/28/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit

class BlogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var featuredImageView : UIImageView!
    @IBOutlet weak var blogTitleLabel : UILabel!
    @IBOutlet weak var backgroundTitleLabelImageView : UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        // Configure the view for the selected state
        let backgroundImageViewColor = backgroundTitleLabelImageView.backgroundColor
        super.setSelected(selected, animated: animated)
        backgroundTitleLabelImageView.backgroundColor = backgroundImageViewColor
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        // Configure the view for the selected state
        let backgroundImageViewColor = backgroundTitleLabelImageView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        backgroundTitleLabelImageView.backgroundColor = backgroundImageViewColor
    }
}
