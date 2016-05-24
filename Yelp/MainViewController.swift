//
//  MainViewController.swift
//  Yelp
//
//  Created by Yat Choi on 5/23/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, FiltersDelegate {
  
  var businesses: [Business]!
  var filteredBusinesses: [Business]!
  
  

  @IBOutlet weak var mainTableView: UITableView!
  
  var currentFilterSet: FilterSet?
  var searchController: UISearchController!
  
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
    let filterButton = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "filterButtonTapped")
    filterButton.tintColor = UIColor.whiteColor()
    navigationItem.leftBarButtonItem = filterButton
    
    // Do Table setup
    self.mainTableView.delegate = self
    self.mainTableView.dataSource = self
    
    self.mainTableView.estimatedRowHeight = 104
    self.mainTableView.rowHeight = UITableViewAutomaticDimension
    
    let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
    self.mainTableView.registerNib(nib, forCellReuseIdentifier: "searchCell")
    
    // Make yelp request
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
    let deals = currentFilterSet?.offeringDeal
    let categoriesArray = currentFilterSet?.getCategoriesArray()
    makeYelpRequestWithTerm("Restaurants", categories: categoriesArray, deals: deals)
  }
  
  func onCancel(filtersViewController: FiltersViewController) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  func getExistingFilters(filtersViewController: FiltersViewController) -> FilterSet? {
    return currentFilterSet
  }
  
  // View Controller functions
  
  func makeYelpRequestWithTerm(term: String) {
    Business.searchWithTerm(term, completion: { (businesses: [Business]!, error: NSError!) -> Void in
      self.businesses = businesses
      self.filteredBusinesses = businesses
      self.mainTableView.reloadData()
    })
  }
  
  func makeYelpRequestWithTerm(term: String, categories: [String]?, deals: Bool?) {
    Business.searchWithTerm(term, sort: nil, categories: categories, deals: deals, completion: { (businesses: [Business]!, error: NSError!) -> Void in
      self.businesses = businesses
      self.filteredBusinesses = businesses
      self.mainTableView.reloadData()
    })
  }
  
  // Event Handlers
  func filterButtonTapped() {
    let filterVC = FiltersViewController()
    filterVC.delegate = self
    self.navigationController?.pushViewController(filterVC, animated: true)
  }
  

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */

}
