//
//  DetailPostViewController.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 4/16/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit
import CoreData

class DetailPostViewController: BaseViewController, UIWebViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingIndicatorView : UIActivityIndicatorView!
    @IBOutlet weak var errorView : UIView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        self.reloadWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -
    // MARK: private methods
    
    func reloadWebView() {
        let indexPath  = NSIndexPath(forRow: 0, inSection: 0)
        let blogPost = fetchedResultsController.objectAtIndexPath(indexPath) as! BlogPost
        self.webView.loadHTMLString(blogPost.contentHTML, baseURL: nil)
    }
    
    // MARK: -
    // MARK: UIWebViewDelegate
    func webViewDidStartLoad(webView: UIWebView) {
        self.loadingIndicatorView.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.loadingIndicatorView.stopAnimating()
    }
    
    // MARK: -
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
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
