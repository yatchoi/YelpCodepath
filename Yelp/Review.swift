//
//  Review.swift
//  Yelp
//
//  Created by Yat Choi on 5/26/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit

class Review: NSObject {
  let ratingImageURL: NSURL?
  let excerpt: String?
  let username: String?
  let userImageURL: NSURL?
  
  init(dictionary: NSDictionary) {
    let ratingImageURLString = dictionary["rating_image_url"] as? String
    if ratingImageURLString != nil {
      ratingImageURL = NSURL(string: ratingImageURLString!)
    } else {
      ratingImageURL = nil
    }
    
    excerpt = dictionary["excerpt"] as? String
    
    username = dictionary["user"]!["name"] as? String
    
    var userImageString = dictionary["user"]!["image_url"] as? String
    if userImageString != nil {
      let replaced = (userImageString! as NSString).stringByReplacingOccurrencesOfString("http://", withString: "https://")
      userImageURL = NSURL(string: replaced)
    } else {
      userImageURL = nil
    }
  }
}
