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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
