//
//  BlogPostParser.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 5/3/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit
import SwiftString3

class BlogPostParser: NNParser {
    
    func parsedDictionaryFromDictionary(_ dictionary : [String : AnyObject]) -> [String : AnyObject]? {
        var parsedDictionary = [String : AnyObject]()
        if let postTitle = dictionary["title"] {
            let encodedPostTitle = postTitle as! String
            let decodedPostTitle = encodedPostTitle.decodeHTML()
            parsedDictionary["postTitle"] = decodedPostTitle as AnyObject?
        }
        
        if let slug = dictionary["slug"] {
            parsedDictionary["slug"] = slug
        }
    
        if let created = dictionary["date"] as? String {
            let createdDate = DateFormatter.getDateFromString(created, dateFormat: "yyyy-MM-dd HH:mm:ss")
            parsedDictionary["createdDate"] = createdDate as AnyObject?
        }
        
        if let contentHTMLString = dictionary["content"] {
            parsedDictionary["contentHTML"] = contentHTMLString
        }
        
        if let postID = dictionary["id"] {
            parsedDictionary["postID"] = postID
        }
        
        if let sourceUrl = dictionary["url"] {
            parsedDictionary["sourceUrl"] = sourceUrl
        }
        
        if let thumbnailDictionary = dictionary["thumbnail_images"] {
            if let thumbnailFull = thumbnailDictionary["full"] as? [String:AnyObject]  {
                if let imageUrl = thumbnailFull["url"] {
                    parsedDictionary["imageUrl"] = imageUrl
                }
            }
        }
        
        return parsedDictionary
    }
    
    func parsedArrayFromArray(_ array: [[String:AnyObject]]) -> [[String:AnyObject]]?{
        var parsedArray = [[String:AnyObject]]()
        for dictionary in array  {
            if let parsedDictionary = parsedDictionaryFromDictionary(dictionary) {
                parsedArray.append(parsedDictionary)
            }
        }
        
        return parsedArray
    }

}
