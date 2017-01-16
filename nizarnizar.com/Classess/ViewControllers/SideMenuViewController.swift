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
        let blogList = storyboard.instantiateViewController(withIdentifier: "BlogListViewController") as! BlogListViewController
        self.blogListViewController = UINavigationController(rootViewController: blogList)
        
        let aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        self.aboutViewController = UINavigationController(rootViewController: aboutVC)
        
        let openSourceVC = storyboard.instantiateViewController(withIdentifier: "OpenSourceViewController") as! OpenSourceViewController
        self.openSourceViewController = UINavigationController(rootViewController: openSourceVC)
        
    }
    
    // MARK: Private Methods
    func changeViewController(_ menu: LeftMenu) {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell", for: indexPath) as! SideMenuTableViewCell
        cell.delegate = self
        switch indexPath.row {
        case 0:
            cell.titleMenuButton.setTitle("Home", for: UIControlState())
            break
        case 1:
            cell.titleMenuButton.setTitle("About", for: UIControlState())
            break
        case 2:
            cell.titleMenuButton.setTitle("Open Source Libraries", for: UIControlState())
            break
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SideMenuViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - SideMenuTableViewCellDelegate
extension SideMenuViewController : SideMenuTableViewCellDelegate {
    func menuButtonDidClicked(_ cell : UITableViewCell) {
        let indexPath = tableView.indexPath(for: cell)
        if let menu = LeftMenu(rawValue: (indexPath?.row)!) {
            self.changeViewController(menu)
        }
    }
}
