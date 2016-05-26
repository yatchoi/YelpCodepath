//
//  YelpClient.swift
//  Yelp
//
//  Created by Timothy Lee on 9/19/14.
//  Copyright (c) 2014 Timothy Lee. All rights reserved.
//

import UIKit

import AFNetworking
import BDBOAuth1Manager

class YelpBusinessClient: BDBOAuth1RequestOperationManager {
  var accessToken: String!
  var accessSecret: String!
  
  class var sharedInstance : YelpBusinessClient {
    struct Static {
      static var token : dispatch_once_t = 0
      static var instance : YelpBusinessClient? = nil
    }
    
    dispatch_once(&Static.token) {
      Static.instance = YelpBusinessClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
    }
    return Static.instance!
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
    self.accessToken = accessToken
    self.accessSecret = accessSecret
    let baseUrl = NSURL(string: "https://api.yelp.com/v2/business/")
    super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
    
    let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
    self.requestSerializer.saveAccessToken(token)
  }
  
  func businessWithId(id: String, completion: (Business!, NSError!) -> Void) -> AFHTTPRequestOperation {
    let idEncoded = id.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    return self.GET(idEncoded!, parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
      let dictionaries = response as? NSDictionary
      if dictionaries != nil {
        completion(Business(dictionary: dictionaries!), nil)
      }
      }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
        completion(nil, error)
    })!
  }
}