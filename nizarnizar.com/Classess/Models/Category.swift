//
//  Category.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 7/30/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Category: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    class func InsertCategoryWithArray(parsedArray: [[String : AnyObject]]) {
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        for dictionary in parsedArray {
            InsertBlogPostWithDictionary(dictionary)
        }
        
        do {
            try managedObjectContext.save()
        } catch let saveError as NSError {
            print("save managedObjectContext error: \(saveError.localizedDescription)")
        }
    }
    
    class func InsertBlogPostWithDictionary(dictionary: [String : AnyObject]) {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let categoryIDString = dictionary["id"]!.stringValue
        // success ...
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicate = NSPredicate(format: "categoryID == %@", categoryIDString)
        fetchRequest.predicate = predicate
        let fetchResults = try! managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        
        if (fetchResults!.count == 0) {
            let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: managedObjectContext) as! Category
            
            if let categoryID : String = categoryIDString {
                category.categoryID = categoryID
            }
            
            if let slug = dictionary["slug"] {
                category.slug = slug as? String
            }
            
            if let title = dictionary["title"] {
                category.title = title as? String
            }
            
            if let descript = dictionary["description"] {
                category.desc = descript as? String
            }
            
            if let postCont = dictionary["post_count"] {
                category.totalPost = NSNumber.init(integer:postCont.integerValue)
            }
        }
    }
    
    class func deleteAllCategories() {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Category", inManagedObjectContext: managedObjectContext)
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
    
    class func fetchAllCategories() -> [NSManagedObject]? {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Category")
        do {
            if let results = try managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                return results
            }
        } catch {
            
        }
        
        return nil
    }
}
