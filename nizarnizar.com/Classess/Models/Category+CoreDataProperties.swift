//
//  Category+CoreDataProperties.swift
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

extension Category {

    @NSManaged var categoryID: String?
    @NSManaged var title: String?
    @NSManaged var slug: String?
    @NSManaged var totalPost: NSNumber?
    @NSManaged var desc: String?

}
