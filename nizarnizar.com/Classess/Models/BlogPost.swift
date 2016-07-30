//
//  BlogPost.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 7/30/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class BlogPost: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
     class func InsertBlogPostWithArray(parsedArray: [[String : AnyObject]], inCategory: Int) {
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        for dictionary in parsedArray {
            InsertBlogPostWithDictionary(dictionary, inCategory: inCategory)
        }
        
        do {
            try managedObjectContext.save()
        } catch let saveError as NSError {
            print("save managedObjectContext error: \(saveError.localizedDescription)")
        }
    }
    
    class func InsertBlogPostWithDictionary(dictionary: [String : AnyObject], inCategory: Int) {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let postIDString = dictionary["postID"]!.stringValue
        // success ...
        let fetchRequest = NSFetchRequest(entityName: "BlogPost")
        let predicate = NSPredicate(format: "postID == %@", postIDString)
        fetchRequest.predicate = predicate
        let fetchResults = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [BlogPost]
        
        if (fetchResults!.count == 0) {
            let blogPost = NSEntityDescription.insertNewObjectForEntityForName("BlogPost", inManagedObjectContext: managedObjectContext) as! BlogPost
            
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
    
    class func deleteAllPost() {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("BlogPost", inManagedObjectContext: managedObjectContext)
        fetchRequest.includesPropertyValues = false
        do {
            if let results = try managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                for result in results {
                    managedObjectContext.deleteObject(result)
                }
                
                try managedObjectContext.save()
            }
        } catch {
            
        }
    }
}
