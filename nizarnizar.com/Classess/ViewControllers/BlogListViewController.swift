//
//  BlogListViewController.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 4/16/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit
import Alamofire

class BlogListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var blogListTableView: UITableView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        requestBlogListWithOffset(0, limit: 0);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section:    Int) -> Int {
        return 10
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BlogTableViewCell", forIndexPath: indexPath) as! BlogTableViewCell
        cell.blogTitleLabel.text = String(indexPath.row)
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
                        
                    }
                    
                    
                    
                    
                    
//                    print(parsedArray)
                }
        }
    }

}
