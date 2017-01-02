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
    
    var clickedLinkRequest : URLRequest?
    
    var postID : String!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BlogPost")
        
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
        webView.isHidden = true
        errorView.isHidden = true
        self.reloadWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - private methods
    
    func reloadWebView() {
        let indexPath  = IndexPath(row: 0, section: 0)
        let blogPost = fetchedResultsController.object(at: indexPath) as? BlogPost
        
        if let blog = blogPost {
            var html = ""
            var style = ""
            
            html = html + "<html>\n"
            html = html + "<head>\n"
            
            style = "<link rel=\"stylesheet\" type=\"text/css\" href=\"yui_reset.css\" media=\"all\" \n/>"
            html = html + style
            
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                style = "<link rel=\"stylesheet\" type=\"text/css\" href=\"single_ipad.css\" media=\"all\" \n/>"
            } else {
                // iPhone
                style = "<link rel=\"stylesheet\" type=\"text/css\" href=\"single.css\" media=\"all\" \n/>";
            }
            
            html = html + style
            
            html = html + "</head>\n"
            html = html + "<body>\n"
            
            html = html + "<div style=\"min-height:100%%; position:relative;\">\n"
            html = html + "<ul class=\"titleContainer\">"
            
            let dateFormat = Foundation.DateFormatter()
            let locale = Locale(identifier:"en_US_POSIX")
            dateFormat.timeStyle = .short
            dateFormat.dateStyle = .long
            dateFormat.locale = locale
            dateFormat.dateFormat = "dd MMMM yyyy"
            
            let postTime = dateFormat.string(from: blog.createdDate)
            
            html = html.appendingFormat("<li class=\"title\">%@</li>", blog.titlePost)
            html = html + "</ul>"
            html = html.appendingFormat("<div class=\"author\">%@</div>",postTime)
            
            html = html + "<div style=\"padding-bottom:10px;\" class =\"contentContainer\">\n<br>"
            html = html + blog.contentHTML
            html = html + "</div>\n"
            html = html + "</div></body>\n"
            html = html + "</html>\n"
            
            let filePath = Bundle.main.resourcePath
            let baseURL = URL(fileURLWithPath: filePath!)
            
            self.webView.loadHTMLString(html, baseURL: baseURL)
        }
    }
    
    func handleError(_ errorString : String?) {
        
        let indexPath  = IndexPath(row: 0, section: 0)
        let blogPost = fetchedResultsController.object(at: indexPath) as? BlogPost
        
        if (blogPost == nil) {
            webView.isHidden = true
            errorView.isHidden = false
            loadingIndicatorView.stopAnimating()
        }
    }
    
    func openImageWithURL(_ url : URL) {
        let agrume = Agrume(imageUrl: url, backgroundBlurStyle: .light)
        agrume.showFrom(self)
    }
    
    // MARK: - Actions
    @IBAction func shareButtonDidClicked(_ sender : UIButton) {
        let indexPath  = IndexPath(row: 0, section: 0)
        let blogPost = fetchedResultsController.object(at: indexPath) as? BlogPost
        if let blog = blogPost {
            let activityViewController = UIActivityViewController(activityItems: [blog.titlePost as NSString, URL(string: blog.sourceUrl)!], applicationActivities: nil)
            present(activityViewController, animated: true, completion: {})
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "showWebBrowserPage") {
            if let webBrowserViewController = segue.destination as? WebBrowserViewController {
                webBrowserViewController.request = clickedLinkRequest!
            }
        }
    }
 

}

// MARK: - UIWebViewDelegate

extension DetailPostViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        webView.isHidden = false
        self.loadingIndicatorView.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.loadingIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if  (error as NSError).code == NSURLErrorCancelled ||
            (error as NSError).code == NSURLErrorFileDoesNotExist {
            // code
            return
        }
        
        handleError(error.localizedDescription)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if (navigationType == .linkClicked) {
            if let urlString = request.url?.absoluteString {
                if (urlString.hasPrefix("http") || urlString.hasPrefix("https")) {
                    clickedLinkRequest = request
                    print("clicked url = ", request.url?.absoluteString ?? "")
                    let imageExtensionArray = ["png", "jpg", "jpeg"]
                    let pathExtension = request.url?.pathExtension
                    
                    if (imageExtensionArray.contains(pathExtension!)) {
                        openImageWithURL(request.url!)
                    } else {
                        performSegue(withIdentifier: "showWebBrowserPage", sender: self)
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
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
}
