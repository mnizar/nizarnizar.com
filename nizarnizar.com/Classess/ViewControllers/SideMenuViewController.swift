//
//  SideMenuViewController.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 7/30/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit

enum LeftMenu: Int {
    case home = 0
    case about
    case openSourceLibraries
}

class SideMenuViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var blogListViewController: UIViewController!
    var aboutViewController: UIViewController!
    var openSourceViewController: UIViewController!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let blogList = storyboard.instantiateViewControllerWithIdentifier("BlogListViewController") as! BlogListViewController
        self.blogListViewController = UINavigationController(rootViewController: blogList)
        
        let aboutVC = storyboard.instantiateViewControllerWithIdentifier("AboutViewController") as! AboutViewController
        self.aboutViewController = UINavigationController(rootViewController: aboutVC)
        
        let openSourceVC = storyboard.instantiateViewControllerWithIdentifier("OpenSourceViewController") as! OpenSourceViewController
        self.openSourceViewController = UINavigationController(rootViewController: openSourceVC)
        
    }
    
    // MARK: Private Methods
    func changeViewController(menu: LeftMenu) {
        switch menu {
        case .home:
            self.slideMenuController()?.changeMainViewController(self.blogListViewController, close: true)
        case .about:
            self.slideMenuController()?.changeMainViewController(self.aboutViewController, close: true)
        case .openSourceLibraries:
            self.slideMenuController()?.changeMainViewController(self.openSourceViewController, close: true)
        }
    }
    
}

// MARK: - UITableViewDataSource
extension SideMenuViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SideMenuTableViewCell", forIndexPath: indexPath) as! SideMenuTableViewCell
        cell.delegate = self
        switch indexPath.row {
        case 0:
            cell.titleMenuButton.setTitle("Home", forState: .Normal)
            break
        case 1:
            cell.titleMenuButton.setTitle("About", forState: .Normal)
            break
        case 2:
            cell.titleMenuButton.setTitle("Open Source Libraries", forState: .Normal)
            break
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SideMenuViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - SideMenuTableViewCellDelegate
extension SideMenuViewController : SideMenuTableViewCellDelegate {
    func menuButtonDidClicked(cell : UITableViewCell) {
        let indexPath = tableView.indexPathForCell(cell)
        if let menu = LeftMenu(rawValue: (indexPath?.row)!) {
            self.changeViewController(menu)
        }
    }
}