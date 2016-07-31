//
//  SideMenuTableViewCell.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 7/30/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit

protocol SideMenuTableViewCellDelegate {
    func menuButtonDidClicked(cell : UITableViewCell)
}

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var titleMenuButton : UIButton!
    var delegate:SideMenuTableViewCellDelegate?
    
    @IBAction func menuButtonDidClicked() {
        delegate?.menuButtonDidClicked(self)
    }
    
}
