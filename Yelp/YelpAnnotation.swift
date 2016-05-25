//
//  YelpAnnotation.swift
//  Yelp
//
//  Created by Yat Choi on 5/25/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit
import MapKit

class YelpAnnotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  
  var photoURL: NSURL?
  var title: String?
  var subtitle: String?
  
  init(title: String, coordinate: CLLocationCoordinate2D, photoURL: NSURL?) {
    self.title = title
    self.coordinate = coordinate
    self.photoURL = photoURL
    super.init()
  }
}
