//
//  LoadingTableViewCell.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 1/16/17.
//  Copyright © 2017 Surocode Inc. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
