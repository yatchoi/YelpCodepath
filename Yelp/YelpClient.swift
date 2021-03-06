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
import MapKit

// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
let yelpConsumerKey = "JezvCG_cmlqyiz-NE9mQlw"
let yelpConsumerSecret = "ziRFewFjh4JwSJTzJczhUdeDNyQ"
let yelpToken = "eKE_hAWP098pySsCEK67SpgmXLDbZ4Xs"
let yelpTokenSecret = "hzydE44DR45VHMBVDW-d2cDbL1w"

enum YelpSortMode: Int {
  case BestMatched = 0, Distance, HighestRated
}

let YelpSortStrings = ["Best Matched", "Distance", "Highest Rated"]

class YelpClient: BDBOAuth1RequestOperationManager {
  var accessToken: String!
  var accessSecret: String!
  
  class var sharedInstance : YelpClient {
    struct Static {
      static var token : dispatch_once_t = 0
      static var instance : YelpClient? = nil
    }
    
    dispatch_once(&Static.token) {
      Static.instance = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
    }
    return Static.instance!
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
    self.accessToken = accessToken
    self.accessSecret = accessSecret
    let baseUrl = NSURL(string: "https://api.yelp.com/v2/")
    super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
    
    let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
    self.requestSerializer.saveAccessToken(token)
  }
  
  func searchWithTerm(term: String, location: CLLocationCoordinate2D, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
    return searchWithTerm(term, sort: nil, categories: nil, deals: nil, offset: nil, location: location, completion: completion)
  }
  
  func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, offset: Int?, location: CLLocationCoordinate2D, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
    // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
    
    // Default the location to San Francisco
    let locationString = "\(location.latitude),\(location.longitude)"
    
    var parameters: [String : AnyObject] = ["term": term, "ll": locationString, "actionlinks": true]
    
    if sort != nil {
      parameters["sort"] = sort!.rawValue
    }
    
    if categories != nil && categories!.count > 0 {
      parameters["category_filter"] = (categories!).joinWithSeparator(",")
    }
    
    if offset != nil && offset > 0 {
      parameters["offset"] = offset
    }
    
    if deals != nil {
      parameters["deals_filter"] = deals!
    }
    
    print(parameters)
    
    return self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
      let dictionaries = response["businesses"] as? [NSDictionary]
      if dictionaries != nil {
        completion(Business.businesses(array: dictionaries!), nil)
      }
      }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
        completion(nil, error)
    })!
  }
}