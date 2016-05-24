//
//  DealCell.swift
//  Yelp
//
//  Created by Yat Choi on 5/23/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit

protocol DealCellDelegate: class {
  func dealCell(switchCell: DealCell, didUpdateValue: Bool)
}

class DealCell: UITableViewCell {
  
  @IBOutlet weak var switchItem: UISwitch!
  
  var delegate: DealCellDelegate?
  
  func populateSwitchCell(delegate: DealCellDelegate, isSet:Bool) {
    self.delegate = delegate
    switchItem.on = isSet
  }
  
  @IBAction func onSwitchValueChanged(sender: AnyObject) {
    self.delegate?.dealCell(self, didUpdateValue: switchItem.on)
  }
}
