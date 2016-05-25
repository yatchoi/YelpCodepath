//
//  SwitchCell.swift
//  Yelp
//
//  Created by Yat Choi on 5/23/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit

protocol SwitchCellDelegate: class {
  func switchCell(switchCell: SwitchCell, didUpdateValue: Bool)
}

class SwitchCell: UITableViewCell {

  @IBOutlet weak var switchName: UILabel!
  @IBOutlet weak var switchItem: UISwitch!
  @IBOutlet weak var bgView: UIView!
  
  var category: String?
  var delegate: SwitchCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }
  
  func populateSwitchCell(delegate: SwitchCellDelegate, name:String, isSet:Bool) {
    self.delegate = delegate
    category = name
    switchName.text = name
    switchItem.on = isSet
    
    let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(SwitchCell.onCellTapped(_:)))
    tapRecognizer.numberOfTapsRequired = 1
    bgView.userInteractionEnabled = true
    bgView.addGestureRecognizer(tapRecognizer)
  }
  
  func onCellTapped(sender: AnyObject) {
    switchItem.on = !switchItem.on
    self.delegate?.switchCell(self, didUpdateValue: switchItem.on)
  }
  
  @IBAction func onSwitchValueChanged(sender: AnyObject) {
    self.delegate?.switchCell(self, didUpdateValue: switchItem.on)
  }
}
