//
//  MapViewController.swift
//  Yelp
//
//  Created by Yat Choi on 5/25/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AlamofireImage

protocol MapViewDelegate: class {
  func onBackTapped(mapViewController: MapViewController)
}

class MapViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!
  
  var delegate: MapViewDelegate?
  var locationManager : CLLocationManager!
  var businesses: [Business]!
  
  override func viewDidLoad() {
      super.viewDidLoad()
    
    mapView.delegate = self

    // Nav setup
    let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(MapViewController.backTapped))
    backButton.tintColor = UIColor.whiteColor()
    navigationItem.leftBarButtonItem = backButton
    
    // Map Setup
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.distanceFilter = 200
    locationManager.requestWhenInUseAuthorization()
    
    for business in businesses {
      addAnnotationAtCoordination(business)
    }
  }
  
  func goToLocation(location: CLLocation) {
    let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    let region = MKCoordinateRegionMake(location.coordinate, span)
    mapView.setRegion(region, animated: false)
  }
  
  func addAnnotationAtCoordination(business:Business) {
    let coordinate = CLLocationCoordinate2D(latitude: business.latitude!, longitude: business.longitude!)
    let annotation = YelpAnnotation(title: business.name!, coordinate: coordinate, photoURL: business.imageURL!)
    annotation.coordinate = coordinate
    annotation.title = business.name
    annotation.subtitle = business.categories
    mapView.addAnnotation(annotation)
  }
  
  func backTapped() {
    delegate?.onBackTapped(self)
  }

}


extension MapViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.AuthorizedWhenInUse {
      locationManager.startUpdatingLocation()
    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      goToLocation(location)
    }
  }
}

extension MapViewController: MKMapViewDelegate {
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if (annotation.isKindOfClass(MKUserLocation)) {
      return nil
    }
    
    let identifier = "customAnnotationView"
    
    // custom image annotation
    var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
    if (annotationView == nil) {
      annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      annotationView?.canShowCallout = true
    }
    else {
      annotationView!.annotation = annotation
    }
    
    if (annotation.isKindOfClass(YelpAnnotation)) {
      let yelpAnnotation = annotation as! YelpAnnotation
      annotationView?.leftCalloutAccessoryView = UIImageView(frame: CGRectMake(0,0,50,50))
      let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
      imageView.af_setImageWithURL(yelpAnnotation.photoURL!)
    }
    
    return annotationView
  }
}
