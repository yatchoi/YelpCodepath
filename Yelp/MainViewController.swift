//
//  MainViewController.swift
//  Yelp
//
//  Created by Yat Choi on 5/23/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, FiltersDelegate, CLLocationManagerDelegate {
  
  var businesses: [Business]!
  var filteredBusinesses: [Business]!
  
  @IBOutlet weak var mainTableView: UITableView!
  
  var currentFilterSet: FilterSet?
  var searchController: UISearchController!
  
  var isMoreDataLoading = false
  var loadingMoreView: InfiniteScrollActivityView?
  
  var locationManager : CLLocationManager!
  var currentLocation: CLLocation!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do Nav setup
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 190, green: 0, blue: 0, alpha: 1)
    
    // Do search bar setup
    searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.sizeToFit()
    searchController.hidesNavigationBarDuringPresentation = false
    
    navigationItem.titleView = searchController.searchBar
    
    definesPresentationContext = true

    // Filter button in nav
    let filterButton = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: #selector(MainViewController.filterButtonTapped))
    filterButton.tintColor = UIColor.whiteColor()
    navigationItem.leftBarButtonItem = filterButton
    
    // Map button in nav
    let mapButton = UIBarButtonItem(title: "Map", style: .Plain , target: self, action: #selector(MainViewController.mapButtonTapped))
    mapButton.tintColor = UIColor.whiteColor()
    navigationItem.rightBarButtonItem = mapButton
    
    // Do Table setup
    self.mainTableView.delegate = self
    self.mainTableView.dataSource = self
    
    self.mainTableView.estimatedRowHeight = 104
    self.mainTableView.rowHeight = UITableViewAutomaticDimension
    
    let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
    self.mainTableView.registerNib(nib, forCellReuseIdentifier: "searchCell")
    
    // Setup infinite scroll activity view
    let frame = CGRectMake(0, mainTableView.contentSize.height, mainTableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
    loadingMoreView = InfiniteScrollActivityView(frame: frame)
    loadingMoreView?.hidden = true
    
    var insets = mainTableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    mainTableView.contentInset = insets
    
    // Make yelp request
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.distanceFilter = 200
    locationManager.requestWhenInUseAuthorization()

    makeYelpRequestWithTerm("Restaurants")
  }
  
  // UITableViewDataSource Functions
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.filteredBusinesses?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = self.mainTableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath) as! SearchTableViewCell
    
    cell.populateCellWithBusiness(filteredBusinesses[indexPath.row])
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let bvc = BusinessViewController()
    bvc.delegate = self
    bvc.business = filteredBusinesses[indexPath.row]
    self.navigationController?.pushViewController(bvc, animated: true)
  }
  
  // UISearchResultUpdating functions
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    if let searchText = searchController.searchBar.text {
      filteredBusinesses = searchText.isEmpty ? businesses : businesses.filter({(data: Business) -> Bool in
        return data.name!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
      })
      
      mainTableView.reloadData()
    }
  }
  
  // FiltersDelegate functions
  func filters(filtersViewController: FiltersViewController, didSaveFilters filterSet:FilterSet) {
    currentFilterSet = filterSet
    self.navigationController?.popViewControllerAnimated(true)
    makeRequestWithCurrentFilters(nil)
  }
  
  func onCancel(filtersViewController: FiltersViewController) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  func getExistingFilters(filtersViewController: FiltersViewController) -> FilterSet? {
    return currentFilterSet
  }
  
  // View Controller functions
  
  func getCurrentLocation() -> CLLocationCoordinate2D {
    if (locationManager.location != nil) {
      self.currentLocation = locationManager.location!
    } else {
      currentLocation = CLLocation(latitude: 37.785771,longitude: -122.406165)
    }
    return self.currentLocation.coordinate
  }
  
  func makeYelpRequestWithTerm(term: String) {
    Business.searchWithTerm(term, location: getCurrentLocation(), completion: { (businesses: [Business]!, error: NSError!) -> Void in
      self.businesses = businesses
      self.filteredBusinesses = businesses
      self.mainTableView.reloadData()
    })
  }
  
  func makeYelpRequestWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, distance: DistanceOption?, offset: Int?) {
    Business.searchWithTerm(term, sort: sort, categories: categories, deals: deals, offset: offset, location: getCurrentLocation(), completion: { (businesses: [Business]!, error: NSError!) -> Void in
      self.isMoreDataLoading = false
      self.loadingMoreView!.stopAnimating()
      var filteredResults = businesses

      if (distance != DistanceOption.Auto) {
        filteredResults = businesses.filter({ (business) -> Bool in
          guard let fullDistanceString = business.distance else {
            return false
          }
          
          if (distance == nil) {
            return true
          }
          
          let distanceString = fullDistanceString.componentsSeparatedByString(" ").first!
          let distanceValue = Double(distanceString)!
          return distanceValue <= DistanceValues[(distance!.rawValue)]
        })
      }
      
      if (offset == nil || offset == 0) {
        self.businesses = businesses
        self.filteredBusinesses = filteredResults
      } else {
        self.businesses.appendContentsOf(businesses)
        self.filteredBusinesses.appendContentsOf(filteredResults)
      }
      
      self.mainTableView.reloadData()
    })
  }
  
  func makeRequestWithCurrentFilters(offset: Int?) {
    let sort = currentFilterSet?.sort
    let deals = currentFilterSet?.offeringDeal
    let categoriesArray = currentFilterSet?.getCategoriesArray()
    let distance = currentFilterSet?.distance
    makeYelpRequestWithTerm("Restaurants", sort: sort, categories: categoriesArray, deals: deals, distance: distance, offset: offset)
  }
  
  // Event Handlers
  func filterButtonTapped() {
    let filterVC = FiltersViewController()
    filterVC.delegate = self
    self.navigationController?.pushViewController(filterVC, animated: true)
  }
  
  // Event Handlers
  func mapButtonTapped() {
    let mapVC = MapViewController()
    mapVC.delegate = self
    mapVC.businesses = self.filteredBusinesses
    self.navigationController?.pushViewController(mapVC, animated: true)
  }

}

extension MainViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if (!isMoreDataLoading) {
      // Calculate the position of one screen length before the bottom of the results
      let scrollViewContentHeight = mainTableView.contentSize.height
      let scrollOffsetThreshold = scrollViewContentHeight - (mainTableView.bounds.size.height * 2)
      
      // When the user has scrolled past the threshold, start requesting
      if(scrollView.contentOffset.y > scrollOffsetThreshold && mainTableView.dragging) {
        isMoreDataLoading = true
        
        // Update position of loadingMoreView, and start loading indicator
        let frame = CGRectMake(0, mainTableView.contentSize.height, mainTableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
        
        makeRequestWithCurrentFilters(self.filteredBusinesses.count)
      }
    }
  }
}

extension MainViewController: MapViewDelegate {
  func onBackTapped(mapViewController: MapViewController) {
    self.navigationController?.popViewControllerAnimated(true)
  }
}

extension MainViewController: BusinessViewDelegate {
  func businessView(onBackTapped businessViewController: BusinessViewController) {
    self.navigationController?.popViewControllerAnimated(true)
  }
}