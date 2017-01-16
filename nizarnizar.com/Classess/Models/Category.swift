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

    class func insertCategoryWithArray(_ parsedArray: [[String : AnyObject]]) {
        
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        
        for dictionary in parsedArray {
            insertBlogPostWithDictionary(dictionary)
        }
        
        do {
            try managedObjectContext.save()
        } catch let saveError as NSError {
            print("save managedObjectContext error: \(saveError.localizedDescription)")
        }
    }
    
    class func insertBlogPostWithDictionary(_ dictionary: [String : AnyObject]) {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let categoryIDString = dictionary["id"]!.stringValue
        // success ...
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: "categoryID == %@", categoryIDString!)
        fetchRequest.predicate = predicate
        let fetchResults = try! managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
        
        if (fetchResults!.count == 0) {
            let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: managedObjectContext) as! Category
            
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
                category.totalPost = NSNumber.init(value: postCont.intValue as Int)
            }
        }
    }
    
    class func deleteAllCategories() {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Category", in: managedObjectContext)
        fetchRequest.includesPropertyValues = false
        do {
            if let results = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
                for result in results {
                    managedObjectContext.delete(result)
                }
                
                try managedObjectContext.save()
            }
        } catch {
            
        }
    }
    
    class func fetchAllCategories() -> [NSManagedObject]? {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        do {
            if let results = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
                return results
            }
        } catch {
            
        }
        
        return nil
    }
}
