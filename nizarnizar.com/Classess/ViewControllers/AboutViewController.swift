//
//  AboutViewController.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 7/30/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit
import SafariServices
import Agrume

enum AboutMenu: Int {
    case linkedin = 0
    case facebook
    case instagram
    case twitter
    case aboutMe
}

class AboutViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(openImage))
        photoImageView.userInteractionEnabled = true
        photoImageView.addGestureRecognizer(tapGesture)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Private Methods
    func openImage() {
        if let image = UIImage(named: "profilePic") {
            let agrume = Agrume(image: image)
            agrume.showFrom(self)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - UITableViewDataSource
extension AboutViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SideMenuTableViewCell", forIndexPath: indexPath) as! SideMenuTableViewCell
        cell.delegate = self
        switch indexPath.row {
        case 0:
            cell.titleMenuButton.setTitle("Linkedin", forState: .Normal)
            break
        case 1:
            cell.titleMenuButton.setTitle("Facebook", forState: .Normal)
            break
        case 2:
            cell.titleMenuButton.setTitle("Instagram", forState: .Normal)
            break
        case 3:
            cell.titleMenuButton.setTitle("Twitter", forState: .Normal)
            break
        case 4:
            cell.titleMenuButton.setTitle("About.me", forState: .Normal)
            break
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AboutViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - SideMenuTableViewCellDelegate
extension AboutViewController : SideMenuTableViewCellDelegate {
    func menuButtonDidClicked(cell : UITableViewCell) {
        let indexPath = tableView.indexPathForCell(cell)
        if let menu = AboutMenu(rawValue: (indexPath?.row)!) {
            var urlString = ""
            switch menu {
            case .linkedin:
                urlString = "https://www.linkedin.com/in/muhammadnizar"
                break
            case .facebook:
                urlString = "https://www.facebook.com/nizarnizar"
                break
            case .instagram:
                urlString = "https://www.instagram.com/nizarnizar"
                break
            case .twitter:
                urlString = "https://www.twitter.com/nizarnizar"
                break
            case .aboutMe:
                urlString = "http://about.me/muhammad.nizar"
                break
            }
            
            let svc = SFSafariViewController(URL: NSURL(string: urlString)!)
            self.presentViewController(svc, animated: true, completion: nil)
        }
    }
}
