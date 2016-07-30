//
//  ContainerViewController.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 7/30/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class ContainerViewController: SlideMenuController {
    override func awakeFromNib() {
        SlideMenuOptions.leftViewWidth = self.view.frame.size.width - 50
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NNNavigationController") {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("SideMenuViewController") {
            self.leftViewController = controller
        }
        
        super.awakeFromNib()
    }
}
