//
//  BusinessViewController.swift
//  Yelp
//
//  Created by Yat Choi on 5/25/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol BusinessViewDelegate: class {
  func businessView(onBackTapped businessViewController:BusinessViewController)
}

class BusinessViewController: UIViewController {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var topImageView: UIImageView!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var categoriesLabel: UILabel!
  @IBOutlet weak var reviewsLabel: UILabel!
  @IBOutlet weak var reviewsImage: UIImageView!
  @IBOutlet weak var orderNowButton: UIButton!
  @IBOutlet weak var makeReservationButton: UIButton!
  @IBOutlet weak var reviewsTable: UITableView!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var scrollView: UIScrollView!
  
  var business: Business!
  var delegate: BusinessViewDelegate?
  
  var locationManager : CLLocationManager!

  override func viewDidLoad() {
    super.viewDidLoad()

    topImageView.af_setImageWithURL(business.imageURL!)
    
    let contentWidth = scrollView.bounds.width
    let contentHeight = scrollView.bounds.height * 3
    scrollView.contentSize = CGSizeMake(contentWidth, contentHeight)
    
    // UI Setup
    nameLabel.text = business.name!
    distanceLabel.text = business.distance!
    categoriesLabel.text = business.categories!
    reviewsLabel.text = "\(business.reviewCount!) Reviews"
    topImageView.af_setImageWithURL(business.imageURL!)
    reviewsImage.af_setImageWithURL(business.ratingImageURL!)
    
    if (business.eat24Url != nil) {
      orderNowButton.enabled = true
    } else {
      orderNowButton.enabled = false
    }
    
    if (business.reservationURL != nil) {
      makeReservationButton.enabled = true
    } else {
      makeReservationButton.enabled = false
    }
    
    // Nav setup
    let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(BusinessViewController.backTapped))
    backButton.tintColor = UIColor.whiteColor()
    navigationItem.leftBarButtonItem = backButton
    
    // Map setup
    mapView.showsUserLocation = true
    
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.distanceFilter = 200
    locationManager.requestWhenInUseAuthorization()
    
    // Review Table setup
    let nib = UINib(nibName: "ReviewTableCell", bundle: nil)
    self.reviewsTable.registerNib(nib, forCellReuseIdentifier: "reviewCell")
    self.reviewsTable.estimatedRowHeight = 104
    self.reviewsTable.rowHeight = UITableViewAutomaticDimension
    
    reviewsTable.dataSource = self
    makeBusinessRequestWithId(business.id!)
  }
  
  @IBAction func orderNowTapped(sender: AnyObject) {
    UIApplication.sharedApplication().openURL(business.eat24Url!)
  }
  
  @IBAction func onReservationTapped(sender: AnyObject) {
    UIApplication.sharedApplication().openURL(business.reservationURL!)
  }
  
  func backTapped() {
    delegate?.businessView(onBackTapped: self)
  }
  
  func makeBusinessRequestWithId(id:String) {
    Business.businessWithId(id) { (business: Business!, error: NSError!) in
      self.business.reviews = business.reviews
      self.reviewsTable.reloadData()
    }
  }
  
  func goToLocation(location: CLLocation) {
    let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    let region = MKCoordinateRegionMake(location.coordinate, span)
    mapView.setRegion(region, animated: false)
  }
}

extension BusinessViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.business.reviews?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = reviewsTable.dequeueReusableCellWithIdentifier("reviewCell") as! ReviewTableCell
    cell.initializeCell(self.business.reviews![indexPath.row])
    return cell
  }
}

extension BusinessViewController: CLLocationManagerDelegate {
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
