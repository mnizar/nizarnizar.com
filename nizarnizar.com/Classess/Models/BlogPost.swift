//
//  BlogPost.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 5/3/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit
import CoreData

class BlogPost: NSManagedObject {
    @NSManaged var titlePost: String
    @NSManaged var contentHTML: String
    @NSManaged var sourceUrl: String
    @NSManaged var createdDate: NSDate
    @NSManaged var modifiedDate: String
    @NSManaged var authorName: String
    @NSManaged var imageUrl: String
    @NSManaged var slug: String
    @NSManaged var postID: String
    
    func insertBlogPostWithArray(array: Array<Dictionary<String, AnyObject>>) {
        for dictionary in array  {
            print("parsedDictionary: \(dictionary)")
        }
    }
}

