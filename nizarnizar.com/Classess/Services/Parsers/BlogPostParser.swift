//
//  BlogPostParser.swift
//  nizarnizar.com
//
//  Created by Muhammad Nizar on 5/3/16.
//  Copyright © 2016 Surocode Inc. All rights reserved.
//

import UIKit
import SwiftString

class BlogPostParser: NNParser {
    
    func parsedDictionaryFromDictionary(dictionary : Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject>? {
        var parsedDictionary = Dictionary<String, AnyObject>()
        if let postTitle = dictionary["title"] {
            let encodedPostTitle = postTitle as! String
            let decodedPostTitle = encodedPostTitle.decodeHTML()
            parsedDictionary["postTitle"] = decodedPostTitle
        }
        
        if let slug = dictionary["slug"] {
            parsedDictionary["slug"] = slug
        }
        
        if let slug = dictionary["content"] {
            parsedDictionary["contentHTML"] = slug
        }
        
        if let postID = dictionary["id"] {
            parsedDictionary["postID"] = postID
        }
        
        if let thumbnailDictionart = dictionary["thumbnail_images"] {
            if let thumbnailFull = thumbnailDictionart["full"] {
                if let imageUrl = thumbnailFull!["url"] {
                    parsedDictionary["imageUrl"] = imageUrl
                }
            }
        }
        
        return parsedDictionary
    }
    
    func parsedArrayFromArray(array: Array<Dictionary<String, AnyObject>>) -> Array<Dictionary<String, AnyObject>>?{
        var parsedArray = Array<Dictionary<String, AnyObject>>()
        for dictionary in array  {
            if let parsedDictionary = parsedDictionaryFromDictionary(dictionary) {
                parsedArray.append(parsedDictionary)
                print("parsedDictionary: \(parsedDictionary)")
            }
        }
        
        return parsedArray
    }

}
