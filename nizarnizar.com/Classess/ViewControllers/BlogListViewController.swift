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
import SDWebImage
import SlideMenuControllerSwift

class BlogListViewController: BaseViewController {
    
    @IBOutlet weak var blogListTableView: UITableView!
    var isFirstTimeLoad : Bool = false
    var isRequesting : Bool = false
    var hasMoreData : Bool = false
    var page : Int = 1
    let limitRequestPerPage : Int = 10
    var refreshControl : UIRefreshControl!
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshControllDidPulled(_:)), forControlEvents: UIControlEvents.ValueChanged)
        blogListTableView.addSubview(refreshControl)

        // Do any additional setup after loading the view.
        self.isFirstTimeLoad = true;
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
        requestBlogListWithOffset(page, limit: limitRequestPerPage);
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - private methods
    
    /*
    func reloadCategories() {
        categoriesArray.removeAll()
        let homeCategoryDictionary = ["title":"Home",
                                      "categoryID": "0"]
        categoriesArray.append(homeCategoryDictionary)
        if let categories = CategoryManager.sharedManager.getAllCategories() {
            for category in categories {
                if let categoryData = category as? Category {
                    let categoryDict : [String : String] = ["title" : categoryData.title!, "categoryID":categoryData.categoryID!]
                    categoriesArray.append(categoryDict)
                }
            }
        }
        
        print(categoriesArray)
        let titleStringArray = categoriesArray.map({$0["title"]! as String})
        print(titleStringArray)
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: "Home", items: titleStringArray)
        menuView.arrowImage = UIImage(named: "arrowDown")
        self.navigationItem.titleView = menuView
        
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
            print(titleStringArray[indexPath])
        }
    }
     */
    
    func configureCell(tableViewCell: BlogTableViewCell , atIndexPath indexPath: NSIndexPath) {
        
        // Fetch Record
        let blogPost = fetchedResultsController.objectAtIndexPath(indexPath) as! BlogPost
        
        // Update Cell
        tableViewCell.blogTitleLabel.text = blogPost.titlePost
        
        if let imageURL = NSURL(string: blogPost.imageUrl) {
            let placeholderImage = UIImage (named: "emptyPlaceholderImage")
            tableViewCell.featuredImageView.sd_setImageWithURL(imageURL, placeholderImage: placeholderImage!)
        }
    }
    
    func triggerLoadingMoreIfNeeded() {
        
        if (!isRequesting && hasMoreData) {
            let currentOffset = blogListTableView.contentOffset.y
            let maximumOffset = blogListTableView.contentSize.height - blogListTableView.frame.size.height
            
            if (maximumOffset - currentOffset < 30) {
                page = page + 1
                requestBlogListWithOffset(page, limit: limitRequestPerPage)
            }
        }
    }

    // MARK: - Actions
    func refreshControllDidPulled(sender:AnyObject) {
        page = 1
        requestBlogListWithOffset(page, limit: limitRequestPerPage)
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
                detailViewController.title = blogPost.titlePost
            }
        }
    }
    
    // MARK : -Request API
    
    func requestBlogListWithOffset(offset : Int, limit: Int) {
        self.isRequesting = true
        Alamofire.request(.GET, "http://nizarnizar.com/blog/", parameters: ["json": "1", "page":offset, "count" : limit])
            .responseJSON { response in
                if (self.refreshControl.refreshing) {
                    self.refreshControl.endRefreshing()
                }
                self.isRequesting = false
                self.isFirstTimeLoad = false
                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    let responsePostArray = JSON["posts"] as! [[String:AnyObject]]
                    if (responsePostArray.count == 0) {
                        self.hasMoreData = false
                    } else {
                        self.hasMoreData = true
                    }
                    
                    if (self.page == 1) {
                        BlogPost.deleteAllPost()
                    }
                    
//                    print(responsePostArray)
                    let parser = BlogPostParser()
                    if let parsedArray = parser.parsedArrayFromArray(responsePostArray) {
                        BlogPost.InsertBlogPostWithArray(parsedArray, inCategory: 0)
                    }
                    
//                    print(parsedArray)
                }
        }
    }
}

// MARK: - UITableViewDataSource
extension BlogListViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let totalPosts = fetchedResultsController.sections![section].numberOfObjects
        if (totalPosts == 0 && self.isFirstTimeLoad) {
            return 1
        } else {
            return totalPosts
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let totalPosts = fetchedResultsController.sections![indexPath.section].numberOfObjects
        if (totalPosts == 0 && self.isFirstTimeLoad) {
            let cell = tableView.dequeueReusableCellWithIdentifier("LoadingCellReuseIdentifier", forIndexPath: indexPath)
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("BlogTableViewCell", forIndexPath: indexPath) as! BlogTableViewCell
            
            configureCell(cell, atIndexPath: indexPath)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension BlogListViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDetailPage", sender: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let totalPosts = fetchedResultsController.sections![indexPath.section].numberOfObjects
        if (totalPosts == 0 && self.isFirstTimeLoad) {
            return tableView.frame.height
        } else {
            return 285.0
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}


// MARK: Fetched Results Controller Delegate Methods

extension BlogListViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.blogListTableView.reloadData()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
    }
}

extension BlogListViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        triggerLoadingMoreIfNeeded()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        triggerLoadingMoreIfNeeded()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        triggerLoadingMoreIfNeeded()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        triggerLoadingMoreIfNeeded()
    }
}

extension BlogListViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        print("SlideMenuControllerDelegate: rightDidClose")
    }
}
