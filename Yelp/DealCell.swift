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
  
  @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var switchItem: UISwitch!
  
  var delegate: DealCellDelegate?
  
  func populateSwitchCell(delegate: DealCellDelegate, isSet:Bool) {
    self.delegate = delegate
    switchItem.on = isSet
    
    let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(DealCell.onCellTapped(_:)))
    tapRecognizer.numberOfTapsRequired = 1
    cellView.userInteractionEnabled = true
    cellView.addGestureRecognizer(tapRecognizer)
  }
  
  func onCellTapped(sender: UITapGestureRecognizer) {
    switchItem.on = !switchItem.on
    self.delegate?.dealCell(self, didUpdateValue: switchItem.on)
  }
  
  @IBAction func onSwitchValueChanged(sender: AnyObject) {
    self.delegate?.dealCell(self, didUpdateValue: switchItem.on)
  }
}
