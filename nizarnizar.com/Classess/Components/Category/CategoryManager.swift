//
//  CategoryManager.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 7/30/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class CategoryManager {

    static let sharedManager = CategoryManager()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    func requestCategories() {
        Alamofire.request(.GET, "http://nizarnizar.com/blog/api/get_category_index", parameters: nil)
            .responseJSON { response in
                print(response.request)  // original URL request
                //                print(response.response) // URL response
                //                print(response.data)     // server data
                //                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    if let responsePostArray = JSON["categories"] as? [[String:AnyObject]] {
                        Category.InsertCategoryWithArray(responsePostArray)
                        NSNotificationCenter.defaultCenter().postNotificationName("RefreshCategoriesNotification", object: nil)
                    }
                    
                }
        }
    }
    
    func getAllCategories() -> [NSManagedObject]? {
        return Category.fetchAllCategories()
    }
}