//
//  BlogListViewController.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 4/16/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import AlamofireImage

class BlogListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var blogListTableView: UITableView!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "BlogPost")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
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
        
        requestBlogListWithOffset(0, limit: 0);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BlogTableViewCell", forIndexPath: indexPath) as! BlogTableViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDetailPage", sender: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func configureCell(tableViewCell: BlogTableViewCell , atIndexPath indexPath: NSIndexPath) {
        
        // Fetch Record
        let blogPost = fetchedResultsController.objectAtIndexPath(indexPath) as! BlogPost
        
        // Update Cell
        tableViewCell.blogTitleLabel.text = blogPost.titlePost
        
        if let imageURL = NSURL(string: blogPost.imageUrl) {
            tableViewCell.featuredImageView.af_setImageWithURL(imageURL)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetailPage"
        {
            if let detailViewController = segue.destinationViewController as? DetailPostViewController {
                let indexPath = self.blogListTableView.indexPathForSelectedRow!
                let blogPost = fetchedResultsController.objectAtIndexPath(indexPath) as! BlogPost
                detailViewController.postID = blogPost.postID
            }
        }
    }
 
    
    // MARK: -
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.blogListTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.blogListTableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                self.blogListTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                self.blogListTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                let cell = self.blogListTableView.cellForRowAtIndexPath(indexPath) as! BlogTableViewCell
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                self.blogListTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                self.blogListTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }
    
    // MARK : -Private Methods
    func requestBlogListWithOffset(offset : Int, limit: Int) {
        Alamofire.request(.GET, "http://nizarnizar.com/blog/", parameters: ["json": "1"])
            .responseJSON { response in
                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    let responsePostArray = JSON["posts"] as! Array<Dictionary<String, AnyObject>>
//                    print(responsePostArray)
                    let parser = BlogPostParser()
                    if let parsedArray = parser.parsedArrayFromArray(responsePostArray) {
                        self.saveToDB(parsedArray)
                    }
                    
//                    print(parsedArray)
                }
        }
    }
    
    func saveToDB (array : Array<Dictionary<String, AnyObject>>) {
        for dictionary in array  {
            let postIDString = dictionary["postID"]!.stringValue
            // success ...
            let fetchRequest = NSFetchRequest(entityName: "BlogPost")
            let predicate = NSPredicate(format: "postID == %@", postIDString)
            fetchRequest.predicate = predicate
            let fetchResults = try! self.managedObjectContext.executeFetchRequest(fetchRequest) as? [BlogPost]
            
            if (fetchResults!.count == 0) {
                let blogPost = NSEntityDescription.insertNewObjectForEntityForName("BlogPost", inManagedObjectContext: self.managedObjectContext) as! BlogPost
                
                if let postID : String = postIDString {
                    blogPost.postID = postID
                }
                
                if let titlePost = dictionary["postTitle"] {
                    blogPost.titlePost = titlePost as! String
                }
                
                if let slug = dictionary["slug"] {
                    blogPost.slug = slug as! String
                }
                
                if let createdDate = dictionary["createdDate"] {
                    blogPost.createdDate = createdDate as! NSDate
                }
                
                if let contentHTML = dictionary["contentHTML"] {
                    blogPost.contentHTML = contentHTML as! String
                }
                
                if let sourceUrl = dictionary["sourceUrl"] {
                    blogPost.sourceUrl = sourceUrl as! String
                }
                
                if let imageUrl = dictionary["imageUrl"] {
                    blogPost.imageUrl = imageUrl as! String
                }
            }
        }
        
        do {
            try self.managedObjectContext.save()
        } catch let saveError as NSError {
            print("save managedObjectContext error: \(saveError.localizedDescription)")
        }
    }

}
