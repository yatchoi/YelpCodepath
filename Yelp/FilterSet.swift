//
//  Filters.swift
//  Yelp
//
//  Created by Yat Choi on 5/23/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit

enum DistanceOption: Int {
  case Auto = 0, OneThirdMile, OneMile, ThreeMiles, FiveMiles
}

let DistanceValues = [0, 0.3, 1, 3, 5]
let DistanceStrings = ["Auto", "0.3 miles", "1 mile", "3 miles", "5 miles"]

class FilterSet: NSObject, NSCopying {
  var offeringDeal: Bool?
  var distance: DistanceOption?
  var sort: YelpSortMode?
  var categories: Dictionary<String, Bool>! // <String, Bool> dictionary
  
  override init() {
    super.init()
    self.offeringDeal = nil
    self.distance = DistanceOption.Auto
    self.sort = YelpSortMode.BestMatched
    self.categories = Dictionary()
  }
  
  func isOfferingDeal() -> Bool {
    if (offeringDeal != nil) {
      return offeringDeal!
    } else {
      return false
    }
  }
  
  func isCategoryOn(categoryName:String) -> Bool {
    if (categories[categoryName] != nil) {
      return categories[categoryName]!
    } else {
      return false
    }
  }
  
  func updateCategory(categoryName:String, value:Bool) {
    categories[categoryName] = value
  }
  
  func getCategoriesArray() -> [String] {
    var categoriesArray = Array<String>()
    for dict in YelpData.getCategories() {
      let key = dict["name"] as! String
      guard let value = categories[key] else {
        continue
      }
      if (value) {
        categoriesArray.append(dict["code"] as! String)
      }
    }
    return categoriesArray
  }
  
  func copyWithZone(zone: NSZone) -> AnyObject {
    let copy = FilterSet()
    copy.offeringDeal = self.offeringDeal
    copy.distance = self.distance
    copy.sort = self.sort
    copy.categories = self.categories
    return copy
  }
}
