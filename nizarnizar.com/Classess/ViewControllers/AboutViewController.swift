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
import MessageUI

enum AboutMenu: Int {
    case linkedin = 0
    case facebook
    case instagram
    case twitter
    case github
    case aboutMe
    case email
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
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["muhamma.nizar@gmail.com"])
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let alertController = UIAlertController(title:NSLocalizedString("Could Not Send Email", comment: ""), message: NSLocalizedString("Your device could not send e-mail.  Please check e-mail configuration and try again", comment:""), preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction) in
            print("You've pressed OK button");
        }
        
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion:nil)
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
        
        return 7
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SideMenuTableViewCell", forIndexPath: indexPath) as! SideMenuTableViewCell
        cell.delegate = self
        if let menu = AboutMenu(rawValue: indexPath.row) {
            var titleString = ""
            switch menu {
            case .linkedin:
                titleString = "Linkedin"
                break
            case .facebook:
                titleString = "Facebook"
                break
            case .instagram:
                titleString = "Instagram"
                break
            case .twitter:
                titleString = "Twitter"
                break
            case .aboutMe:
                titleString = "About.me"
                break
            case .github:
                titleString = "Github"
                break
            case .email:
                titleString = "Email"
                break
            }
            cell.titleMenuButton.setTitle(titleString, forState: .Normal)
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

// MARK: MFMailComposeViewControllerDelegate
extension AboutViewController : MFMailComposeViewControllerDelegate {

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
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
            case .github:
                urlString = "https://github.com/mnizar"
                break
            case .email:
                urlString = "muhamma.nizar@gmail.com"
                break
            }
            
            if (menu == .email) {
                let mailComposeViewController = configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
            } else {
                let svc = SFSafariViewController(URL: NSURL(string: urlString)!)
                self.presentViewController(svc, animated: true, completion: nil)
            }
        }
    }
}
