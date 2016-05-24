//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Yat Choi on 5/23/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit

protocol FiltersDelegate: class {
  func filters(filtersViewController: FiltersViewController, didSaveFilters filterSet:FilterSet)
  func onCancel(filtersViewController: FiltersViewController)
  func getExistingFilters(filtersViewController: FiltersViewController) -> FilterSet?
}

class FiltersViewController: UIViewController, UITableViewDataSource, SeeAllCellDelegate, DealCellDelegate, SwitchCellDelegate, ExpandableOptionDelegate, RadioCellDelegate {

  @IBOutlet weak var categoriesTableView: UITableView!
  
  var delegate: FiltersDelegate?
  
  var categoriesExpanded = false
  var distanceExpanded = false
  var sortByExpanded = false
  
  var dirtyFilterSet = FilterSet(dictionary: nil)
  let fullCategories = YelpData.getCategories()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Nav setup
    let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(FiltersViewController.cancelTapped))
    cancelButton.tintColor = UIColor.whiteColor()
    navigationItem.leftBarButtonItem = cancelButton
    
    let searchButton = UIBarButtonItem(title: "Search", style: .Plain, target: self, action: #selector(FiltersViewController.searchTapped))
    searchButton.tintColor = UIColor.whiteColor()
    navigationItem.rightBarButtonItem = searchButton
    
    // Load existing filters
    if let existingFilters = delegate?.getExistingFilters(self) {
      dirtyFilterSet = existingFilters
    }
    
    // Table setup
    categoriesTableView.dataSource = self
  
    let switchNib = UINib(nibName: "SwitchCell", bundle: nil)
    let dealNib = UINib(nibName: "DealCell", bundle: nil)
    let seeAllNib = UINib(nibName: "SeeAllCell", bundle: nil)
    let expandableNib = UINib(nibName: "ExpandableOptionCell", bundle: nil)
    let radioNib = UINib(nibName: "RadioCell", bundle: nil)
    self.categoriesTableView.registerNib(switchNib, forCellReuseIdentifier: "switchCell")
    self.categoriesTableView.registerNib(dealNib, forCellReuseIdentifier: "dealCell")
    self.categoriesTableView.registerNib(seeAllNib, forCellReuseIdentifier: "seeAllCell")
    self.categoriesTableView.registerNib(expandableNib, forCellReuseIdentifier: "expandableCell")
    self.categoriesTableView.registerNib(radioNib, forCellReuseIdentifier: "radioCell")
  }
  
  
  // Categories UITableViewDataSource functions
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 4
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 0) {
      return 1;
    }
    if (section == 1) {
      if distanceExpanded {
        return 5;
      } else {
        return 1;
      }
    }
    if (section == 2) {
      if sortByExpanded {
        return 3;
      } else {
        return 1;
      }
    }
    if (section == 3) {
      if categoriesExpanded {
        return fullCategories.count ?? 0;
      } else {
        return 4;
      }
    } else {
      return 1;
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let row = indexPath.row
    let section = indexPath.section
    
    if (section == 0) {
      let cell = categoriesTableView.dequeueReusableCellWithIdentifier("dealCell", forIndexPath: indexPath) as! DealCell
      cell.populateSwitchCell(self, isSet: dirtyFilterSet.isOfferingDeal())
      return cell
    }
    
    if (section == 1) {
      let cell = categoriesTableView.dequeueReusableCellWithIdentifier("expandableCell", forIndexPath: indexPath) as! ExpandableOptionCell
      cell.initializeCell(self, forIndexPath: indexPath, name: YelpSortStrings[dirtyFilterSet.sort!.rawValue])
      return cell
    }
    
    if (section == 2) {
      if (sortByExpanded) {
        let cell = categoriesTableView.dequeueReusableCellWithIdentifier("radioCell", forIndexPath: indexPath) as! RadioCell
        cell.initializeCell(self, name: YelpSortStrings[indexPath.row], isSet: true)
        return cell
      } else {
        let cell = categoriesTableView.dequeueReusableCellWithIdentifier("expandableCell", forIndexPath: indexPath) as! ExpandableOptionCell
        cell.initializeCell(self, forIndexPath: indexPath, name: YelpSortStrings[dirtyFilterSet.sort!.rawValue])
        return cell
      }
    }
    
    if (section == 3) {
      if (!categoriesExpanded && row == 3) {
        let cell = categoriesTableView.dequeueReusableCellWithIdentifier("seeAllCell", forIndexPath: indexPath) as! SeeAllCell
        cell.delegate = self
        return cell
      }
      let cell = categoriesTableView.dequeueReusableCellWithIdentifier("switchCell", forIndexPath: indexPath) as! SwitchCell
      guard let name = fullCategories[row]["name"] as? String else {
        return cell
      }
      let isSet = dirtyFilterSet.isCategoryOn(name)
      cell.populateSwitchCell(self, name: name, isSet: isSet)
      
      return cell
    }
    
    return UITableViewCell()
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return ""
      
    case 1:
      return "Distance"
      
    case 2:
      return "Sort By"
      
    case 3:
      return "Category"
      
    default:
      return ""
    }
  }
  
  // SeeAllCellDelegate functions
  func onSeeAllTapped(seeAllCell: SeeAllCell) {
    categoriesExpanded = true
    categoriesTableView.reloadData()
  }
  
  // DealCellDelegate functions
  func dealCell(switchCell: DealCell, didUpdateValue: Bool) {
    dirtyFilterSet.offeringDeal = didUpdateValue
  }
  
  // SwitchCellDelegate functions
  func switchCell(switchCell: SwitchCell, didUpdateValue: Bool) {
    dirtyFilterSet.updateCategory(switchCell.category!, value: didUpdateValue)
  }
  
  // ExpandableOptionDelegate functions
  func onExpand(expandableOptionCell: ExpandableOptionCell) {
    let indexPath = expandableOptionCell.forIndexPath!
    var indexPathsToInsert = Array<NSIndexPath>()
    var numNewRows = 0

    if (indexPath.section == 1) {
      distanceExpanded = true
      numNewRows = 5
    }
    if (indexPath.section == 2) {
      sortByExpanded = true
      numNewRows = 3
    }
    for i in 0...(numNewRows-1) {
      indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: indexPath.section))
    }
    if (numNewRows > 0) {
      self.categoriesTableView.beginUpdates()
      self.categoriesTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow:0, inSection: indexPath.section)], withRowAnimation: UITableViewRowAnimation.None)
      self.categoriesTableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: UITableViewRowAnimation.Top)
      self.categoriesTableView.endUpdates()
    }
  }
  
  // RadioCellDelegate functions
  func onButtonTapped(radioCell: RadioCell) {
    
  }
  
  // Event Handlers
  func cancelTapped() {
    delegate?.onCancel(self)
  }
  
  func searchTapped () {
    delegate?.filters(self, didSaveFilters: dirtyFilterSet)
  }
  
  // Categories
  

}
