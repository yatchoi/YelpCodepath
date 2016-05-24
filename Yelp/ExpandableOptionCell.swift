//
//  ExpandableOptionCell.swift
//  Yelp
//
//  Created by Yat Choi on 5/24/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit

protocol ExpandableOptionDelegate: class {
  func onExpand(expandableOptionCell: ExpandableOptionCell)
}

class ExpandableOptionCell: UITableViewCell {

  @IBOutlet weak var optionLabel: UILabel!
  @IBOutlet weak var buttonView: UIView!
  @IBOutlet weak var mainButton: UIButton!
  
  var delegate: ExpandableOptionDelegate?
  var forIndexPath: NSIndexPath?
  
  func initializeCell(delegate:ExpandableOptionDelegate, forIndexPath:NSIndexPath, name:String) {
    self.delegate = delegate
    self.forIndexPath = forIndexPath
    self.optionLabel.text = name
  }
    
  @IBAction func buttonTapped(sender: AnyObject) {
    delegate?.onExpand(self)
  }
}
