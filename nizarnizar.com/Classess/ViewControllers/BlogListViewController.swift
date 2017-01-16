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
    var isRequesting : Bool = false
    var hasMoreData : Bool = false
    var page : Int = 1
    let limitRequestPerPage : Int = 10
    var refreshControl : UIRefreshControl!
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = { 
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BlogPost")
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshControllDidPulled(_:)), for: UIControlEvents.valueChanged)
        blogListTableView.addSubview(refreshControl)

        // Do any additional setup after loading the view.
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
    
    func configureCell(_ tableViewCell: BlogTableViewCell , atIndexPath indexPath: IndexPath) {
        
        // Fetch Record
        let blogPost = fetchedResultsController.object(at: indexPath) as! BlogPost
        
        // Update Cell
        tableViewCell.blogTitleLabel.text = blogPost.titlePost
        
        if let imageURL = URL(string: blogPost.imageUrl) {
            let placeholderImage = UIImage (named: "emptyPlaceholderImage")
            tableViewCell.featuredImageView.sd_setImage(with: imageURL, placeholderImage: placeholderImage!)
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
    func refreshControllDidPulled(_ sender:AnyObject) {
        page = 1
        requestBlogListWithOffset(page, limit: limitRequestPerPage)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetailPage"
        {
            if let detailViewController = segue.destination as? DetailPostViewController {
                let indexPath = self.blogListTableView.indexPathForSelectedRow!
                let blogPost = fetchedResultsController.object(at: indexPath) as! BlogPost
                detailViewController.postID = blogPost.postID
                detailViewController.title = blogPost.titlePost
            }
        }
    }
    
    // MARK : -Request API
    
    func requestBlogListWithOffset(_ offset : Int, limit: Int) {
        self.isRequesting = true
        Alamofire.request("http://nizarnizar.com/blog/", parameters: ["json": "1", "page":offset, "count" : limit])
            .responseJSON { response in
                if (self.refreshControl.isRefreshing) {
                    self.refreshControl.endRefreshing()
                }
                self.isRequesting = false
                print(response.request?.url?.absoluteString ?? "")  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value as? [String:AnyObject] {
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
                        BlogPost.insertBlogPostWithArray(parsedArray, inCategory: 0)
                    }
                    
//                    print(parsedArray)
                }
                
                self.blogListTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension BlogListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            var totalPost = currentSection.numberOfObjects
            if (totalPost > 0) {
                if (hasMoreData) {
                    totalPost = totalPost + 1
                }
                return totalPost
            }
        }
        
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[indexPath.section]
            let totalPost = currentSection.numberOfObjects
            if (totalPost > 0) {
                if (hasMoreData && indexPath.row == totalPost) {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCellReuseIdentifier", for: indexPath) as! LoadingTableViewCell
                    cell.loadingIndicatorView.startAnimating()
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "BlogTableViewCell", for: indexPath) as! BlogTableViewCell
                    
                    configureCell(cell, atIndexPath: indexPath)
                    return cell
                }
            }
        }
        if (isRequesting) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCellReuseIdentifier", for: indexPath) as! LoadingTableViewCell
            cell.loadingIndicatorView.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCellReuseIdentifier", for: indexPath)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension BlogListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[indexPath.section]
            let totalPost = currentSection.numberOfObjects
            if (totalPost > 0) {
                if (hasMoreData && indexPath.row == totalPost) {
                    
                } else {
                    performSegue(withIdentifier: "showDetailPage", sender: nil)
                }
                
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[indexPath.section]
            let totalPost = currentSection.numberOfObjects
            if (totalPost > 0) {
                if (hasMoreData && indexPath.row == totalPost) {
                    return 80
                } else {
                    return 285
                }
                
            }
        }
        
        return tableView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}


// MARK: Fetched Results Controller Delegate Methods

extension BlogListViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.blogListTableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
}

extension BlogListViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        triggerLoadingMoreIfNeeded()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        triggerLoadingMoreIfNeeded()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        triggerLoadingMoreIfNeeded()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
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
