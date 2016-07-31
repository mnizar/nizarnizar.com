//
//  DetailPostViewController.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 4/16/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit
import CoreData
import Agrume
import SDWebImage

class DetailPostViewController: BaseViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingIndicatorView : UIActivityIndicatorView!
    @IBOutlet weak var errorView : UIView!
    @IBOutlet weak var shareButton : UIButton!
    
    var clickedLinkRequest : NSURLRequest?
    
    var postID : String!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "BlogPost")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        let predicate = NSPredicate(format: "postID == %@", self.postID)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        webView.hidden = true
        errorView.hidden = true
        self.reloadWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - private methods
    
    func reloadWebView() {
        let indexPath  = NSIndexPath(forRow: 0, inSection: 0)
        let blogPost = fetchedResultsController.objectAtIndexPath(indexPath) as? BlogPost
        
        if let blog = blogPost {
            var html = ""
            var style = ""
            
            html = html.stringByAppendingString("<html>\n")
            html = html.stringByAppendingString("<head>\n")
            
            style = "<link rel=\"stylesheet\" type=\"text/css\" href=\"yui_reset.css\" media=\"all\" \n/>"
            html = html.stringByAppendingString(style)
            
            if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                style = "<link rel=\"stylesheet\" type=\"text/css\" href=\"single_ipad.css\" media=\"all\" \n/>"
            } else {
                // iPhone
                style = "<link rel=\"stylesheet\" type=\"text/css\" href=\"single.css\" media=\"all\" \n/>";
            }
            
            html = html.stringByAppendingString(style)
            
            html = html.stringByAppendingString("</head>\n")
            html = html.stringByAppendingString("<body>\n")
            
            html = html.stringByAppendingString("<div style=\"min-height:100%%; position:relative;\">\n")
            html = html.stringByAppendingString("<ul class=\"titleContainer\">")
            
            let dateFormat = NSDateFormatter()
            let locale = NSLocale(localeIdentifier:"en_US_POSIX")
            dateFormat.timeStyle = .ShortStyle
            dateFormat.dateStyle = .LongStyle
            dateFormat.locale = locale
            dateFormat.dateFormat = "dd MMMM yyyy"
            
            let postTime = dateFormat.stringFromDate(blog.createdDate)
            
            html = html.stringByAppendingFormat("<li class=\"title\">%@</li>", blog.titlePost)
            html = html.stringByAppendingString("</ul>")
            html = html.stringByAppendingFormat("<div class=\"author\">%@</div>",postTime)
            
            html = html.stringByAppendingString("<div style=\"padding-bottom:10px;\" class =\"contentContainer\">\n<br>")
            html = html.stringByAppendingString(blog.contentHTML)
            html = html.stringByAppendingString("</div>\n")
            html = html.stringByAppendingString("</div></body>\n")
            html = html.stringByAppendingString("</html>\n")
            
            let filePath = NSBundle.mainBundle().resourcePath
            let baseURL = NSURL.fileURLWithPath(filePath!)
            
            self.webView.loadHTMLString(html, baseURL: baseURL)
        }
    }
    
    func handleError(errorString : String?) {
        
        let indexPath  = NSIndexPath(forRow: 0, inSection: 0)
        let blogPost = fetchedResultsController.objectAtIndexPath(indexPath) as? BlogPost
        
        if (blogPost == nil) {
            webView.hidden = true
            errorView.hidden = false
            loadingIndicatorView.stopAnimating()
        }
    }
    
    func openImageWithURL(url : NSURL) {
        let agrume = Agrume(imageURL: url, backgroundBlurStyle: .Light)
        agrume.download = { url, completion in
            let manager = SDWebImageManager.sharedManager()
            manager.downloadImageWithURL(url,
                                         options: .RefreshCached,
                                         progress: nil, completed: { (image:UIImage!, error:NSError!, cacheType:SDImageCacheType, finished:Bool, url:NSURL!) -> Void in
                                            
                                            if (image != nil) {
                                                completion(image: image)
                                            } else {
                                                completion(image: nil)
                                            }
            })
        }
        agrume.showFrom(self)
    }
    
    // MARK: - Actions
    @IBAction func shareButtonDidClicked(sender : UIButton) {
        let indexPath  = NSIndexPath(forRow: 0, inSection: 0)
        let blogPost = fetchedResultsController.objectAtIndexPath(indexPath) as? BlogPost
        if let blog = blogPost {
            let activityViewController = UIActivityViewController(activityItems: [blog.titlePost as NSString, NSURL(string: blog.sourceUrl)!], applicationActivities: nil)
            presentViewController(activityViewController, animated: true, completion: {})
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "showWebBrowserPage") {
            if let webBrowserViewController = segue.destinationViewController as? WebBrowserViewController {
                webBrowserViewController.request = clickedLinkRequest!
            }
        }
    }
 

}

// MARK: - UIWebViewDelegate

extension DetailPostViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(webView: UIWebView) {
        webView.hidden = false
        self.loadingIndicatorView.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.loadingIndicatorView.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if (error?.code == NSURLErrorCancelled ||
            error?.code == NSURLErrorFileDoesNotExist) {
            return
        }
        
        handleError(error?.localizedDescription)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if (navigationType == .LinkClicked) {
            if let urlString = request.URL?.absoluteString {
                if (urlString.hasPrefix("http") || urlString.hasPrefix("https")) {
                    clickedLinkRequest = request
                    print("clicked url = ", request.URL?.absoluteString)
                    let imageExtensionArray = ["png", "jpg", "jpeg"]
                    let pathExtension = request.URL?.pathExtension
                    
                    if (imageExtensionArray.contains(pathExtension!)) {
                        openImageWithURL(request.URL!)
                    } else {
                        performSegueWithIdentifier("showWebBrowserPage", sender: self)
                    }
                    
                    return false
                }
            }
        }
        
        return true
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DetailPostViewController: NSFetchedResultsControllerDelegate {
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
    }
}
