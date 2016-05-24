//
//  Filters.swift
//  Yelp
//
//  Created by Yat Choi on 5/23/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit

enum SortOption: String {
  case BestMatch = "Best Match"
  case Distance = "Distance"
  case HighestRated = "Highest Rated"
}

class FilterSet: NSObject {
  var offeringDeal: Bool?
  var distance: NSNumber?
  var sort: YelpSortMode?
  var categories: Dictionary<String, Bool>! // <String, Bool> dictionary
  
  init(dictionary: NSDictionary?) {
    if let offeringDeal = dictionary?["deal"] as? Bool {
      self.offeringDeal = offeringDeal
    } else {
      self.offeringDeal = nil
    }
    
    if let distance = dictionary?["distance"] as? NSNumber {
      self.distance = distance
    } else {
      self.distance = nil
    }
    
    if let sort = dictionary?["sortBy"] as? YelpSortMode {
      self.sort = sort
    } else {
      self.sort = YelpSortMode.BestMatched
    }
    
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
}
