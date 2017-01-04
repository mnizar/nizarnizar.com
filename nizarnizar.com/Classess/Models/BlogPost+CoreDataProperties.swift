//
//  BlogPost+CoreDataProperties.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 7/30/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BlogPost {

    @NSManaged var titlePost: String
    @NSManaged var contentHTML: String
    @NSManaged var sourceUrl: String
    @NSManaged var createdDate: Date
    @NSManaged var modifiedDate: String
    @NSManaged var authorName: String
    @NSManaged var imageUrl: String
    @NSManaged var slug: String
    @NSManaged var postID: String

}
