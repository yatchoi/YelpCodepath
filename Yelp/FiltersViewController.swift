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

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SeeAllCellDelegate, DealCellDelegate, SwitchCellDelegate, ExpandableOptionDelegate, RadioCellDelegate {

  @IBOutlet weak var categoriesTableView: UITableView!
  
  var delegate: FiltersDelegate?
  
  var categoriesExpanded = false
  
  var dirtyFilterSet = FilterSet()
  let fullCategories = YelpData.getCategories()
  
  var tableData: [Int: NSMutableDictionary] = [
    0: [
      "header": "Deals",
      "expandable": false,
      "numRows": 1
    ],
    1: [
      "header": "Distance",
      "expandable": true,
      "isExpanded": false,
      "numCollapsedRows": 1,
      "numExpandedRows": 5
    ],
    2: [
      "header": "Sort By",
      "expandable": true,
      "isExpanded": false,
      "numCollapsedRows": 1,
      "numExpandedRows": 3
    ],
    3: [
      "header": "Category",
      "expandable": true,
      "isExpanded": false,
      "numCollapsedRows": 4,
      "numExpandedRows": YelpData.getCategories().count ?? 0
    ]
  ]
  
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
      dirtyFilterSet = existingFilters.copy() as! FilterSet
    }
    
    // Table setup
    categoriesTableView.dataSource = self
    categoriesTableView.delegate = self
    categoriesTableView.tableFooterView = UIView()
  
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
    let sectionData = tableData[section]!
    
    if ((sectionData["expandable"] as! Bool) == true) {
      if ((sectionData["isExpanded"] as! Bool) == true) {
        return sectionData["numExpandedRows"] as! Int
      } else {
        return sectionData["numCollapsedRows"] as! Int
      }
    } else {
      return sectionData["numRows"] as! Int
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let row = indexPath.row
    let section = indexPath.section
    
    let sectionData = tableData[section]!
    
    if (section == 0) {
      let cell = categoriesTableView.dequeueReusableCellWithIdentifier("dealCell", forIndexPath: indexPath) as! DealCell
      cell.populateSwitchCell(self, isSet: dirtyFilterSet.isOfferingDeal())
      return cell
    }
    
    if (section == 1) {
      if (sectionData["isExpanded"] as! Bool == true) {
        let cell = categoriesTableView.dequeueReusableCellWithIdentifier("radioCell", forIndexPath: indexPath) as! RadioCell
        cell.initializeCell(self, name: DistanceStrings[indexPath.row], isSet: dirtyFilterSet.distance!.rawValue == indexPath.row)
        return cell
      } else {
        let cell = categoriesTableView.dequeueReusableCellWithIdentifier("expandableCell", forIndexPath: indexPath) as! ExpandableOptionCell
        cell.initializeCell(self, forIndexPath: indexPath, name: DistanceStrings[dirtyFilterSet.distance!.rawValue])
        return cell
      }
    }
    
    if (section == 2) {
      if (sectionData["isExpanded"] as! Bool == true) {
        let cell = categoriesTableView.dequeueReusableCellWithIdentifier("radioCell", forIndexPath: indexPath) as! RadioCell
        cell.initializeCell(self, name: YelpSortStrings[indexPath.row], isSet: dirtyFilterSet.sort!.rawValue == indexPath.row)
        return cell
      } else {
        let cell = categoriesTableView.dequeueReusableCellWithIdentifier("expandableCell", forIndexPath: indexPath) as! ExpandableOptionCell
        cell.initializeCell(self, forIndexPath: indexPath, name: YelpSortStrings[dirtyFilterSet.sort!.rawValue])
        return cell
      }
    }
    
    if (section == 3) {
      if (sectionData["isExpanded"] as! Bool == false && row == 3) {
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
    let sectionData = tableData[section]! as NSDictionary
    return sectionData["header"] as? String
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let sectionData = tableData[section]! as NSDictionary
    
    if sectionData["header"] as? String != "" {
      let headerView = UIView.init(frame: CGRectMake(0,0,categoriesTableView.bounds.width, 120))
      headerView.backgroundColor = UIColor(red: 126.0/255.0, green: 26.0/255.0, blue: 36.0/255.0, alpha: 1.0)
      
      let label = UILabel(frame: .zero)
      label.font = UIFont(name: "Helvetica", size: 14)
      label.text = sectionData["header"] as? String
      label.textColor = UIColor.whiteColor()
      
      headerView.addSubview(label)
      label.translatesAutoresizingMaskIntoConstraints = false
      
      let leading = NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: headerView, attribute: .Leading, multiplier: 1, constant: 10)
      let centerY = NSLayoutConstraint.init(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: headerView, attribute: .CenterY, multiplier: 1, constant: 0)

      headerView.addConstraint(leading)
      headerView.addConstraint(centerY)
      
      return headerView
    }
    return nil
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 20
  }
  
  // SeeAllCellDelegate functions
  func onSeeAllTapped(seeAllCell: SeeAllCell) {
    guard let indexPath = self.categoriesTableView.indexPathForCell(seeAllCell) else {
      return
    }
    tableData[indexPath.section]!.setValue(true, forKey: "isExpanded")
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

    tableData[indexPath.section]!.setValue(true, forKey: "isExpanded")
    let numNewRows = tableData[indexPath.section]!["numExpandedRows"] as! Int
    
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
    guard let indexPath = self.categoriesTableView.indexPathForCell(radioCell) else {
      return
    }
    
    if (indexPath.section == 1) {
      dirtyFilterSet.distance = DistanceOption(rawValue: indexPath.row)
    }
    
    if (indexPath.section == 2) {
      dirtyFilterSet.sort = YelpSortMode(rawValue: indexPath.row)
    }
    
    collapseSection(indexPath.section)
  }
  
  // UITableViewDelegate functions
  func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
  
  // Event Handlers
  func cancelTapped() {
    delegate?.onCancel(self)
  }
  
  func searchTapped () {
    delegate?.filters(self, didSaveFilters: dirtyFilterSet)
  }
  
  // View functions
  func collapseSection(section: Int) {
    var indexPathsToRemove = Array<NSIndexPath>()
    
    tableData[section]!.setValue(false, forKey: "isExpanded")
    
    let numRows = self.categoriesTableView.numberOfRowsInSection(section)
    for i in 0...(numRows - 1) {
      indexPathsToRemove.append(NSIndexPath(forRow: i, inSection: section))
    }
    
    self.categoriesTableView.beginUpdates()
    self.categoriesTableView.deleteRowsAtIndexPaths(indexPathsToRemove, withRowAnimation: UITableViewRowAnimation.Bottom)
    self.categoriesTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: section)], withRowAnimation: UITableViewRowAnimation.None)
    self.categoriesTableView.endUpdates()
  }
  

}
