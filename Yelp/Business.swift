//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class Business: NSObject {
  let id: String?
  let name: String?
  let address: String?
  let imageURL: NSURL?
  let categories: String?
  let distance: String?
  let ratingImageURL: NSURL?
  let reviewCount: NSNumber?
  let latitude: Double?
  let longitude: Double?
  let eat24Url: NSURL?
  let reservationURL: NSURL?
  var reviews: [Review]?
  
  init(dictionary: NSDictionary) {
    id = dictionary["id"] as? String
    name = dictionary["name"] as? String
    
    let imageURLString = dictionary["image_url"] as? String
    if imageURLString != nil {
      imageURL = NSURL(string: imageURLString!)!
    } else {
      imageURL = nil
    }
    
    let location = dictionary["location"] as? NSDictionary
    var address = ""
    var latitude = 0.0
    var longitude = 0.0
    if location != nil {
      let addressArray = location!["address"] as? NSArray
      if addressArray != nil && addressArray!.count > 0 {
        address = addressArray![0] as! String
      }
      
      let neighborhoods = location!["neighborhoods"] as? NSArray
      if neighborhoods != nil && neighborhoods!.count > 0 {
        if !address.isEmpty {
          address += ", "
        }
        address += neighborhoods![0] as! String
      }
      
      let coordinates = location!["coordinate"] as? NSDictionary
      if coordinates != nil {
        latitude = coordinates!["latitude"] as! Double
        longitude = coordinates!["longitude"] as! Double
      }
    }
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
    
    let categoriesArray = dictionary["categories"] as? [[String]]
    if categoriesArray != nil {
      var categoryNames = [String]()
      for category in categoriesArray! {
        let categoryName = category[0]
        categoryNames.append(categoryName)
      }
      categories = categoryNames.joinWithSeparator(", ")
    } else {
      categories = nil
    }
    
    let distanceMeters = dictionary["distance"] as? NSNumber
    if distanceMeters != nil {
      let milesPerMeter = 0.000621371
      distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
    } else {
      distance = nil
    }
    
    let ratingImageURLString = dictionary["rating_img_url_large"] as? String
    if ratingImageURLString != nil {
      ratingImageURL = NSURL(string: ratingImageURLString!)
    } else {
      ratingImageURL = nil
    }
    
    let eat24UrlString = dictionary["eat24_url"] as? String
    if eat24UrlString != nil {
      eat24Url = NSURL(string: eat24UrlString!)
    } else {
      eat24Url = nil
    }
    
    let reservationURLString = dictionary["reservation_url"] as? String
    if reservationURLString != nil {
      reservationURL = NSURL(string: reservationURLString!)
    } else {
      reservationURL = nil
    }
    
    reviewCount = dictionary["review_count"] as? NSNumber
    
    let reviews = dictionary["reviews"] as? NSArray
    if (reviews != nil && reviews!.count > 0) {
      let review = Review(dictionary: reviews![0] as! NSDictionary)
      self.reviews = [review]
    } else {
      self.reviews = nil
    }
  }
  
  class func businesses(array array: [NSDictionary]) -> [Business] {
    var businesses = [Business]()
    for dictionary in array {
      let business = Business(dictionary: dictionary)
      businesses.append(business)
    }
    return businesses
  }
  
  class func searchWithTerm(term: String, location: CLLocationCoordinate2D, completion: ([Business]!, NSError!) -> Void) {
    YelpClient.sharedInstance.searchWithTerm(term, location: location, completion: completion)
  }
  
  class func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, offset: Int?, location: CLLocationCoordinate2D, completion: ([Business]!, NSError!) -> Void) -> Void {
    YelpClient.sharedInstance.searchWithTerm(term, sort: sort, categories: categories, deals: deals, offset: offset, location: location, completion: completion)
  }
  
  class func businessWithId(id: String, completion: (Business!, NSError!) -> Void) {
    YelpBusinessClient.sharedInstance.businessWithId(id, completion: completion)
  }
}