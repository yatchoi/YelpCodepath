//
//  RadioCell.swift
//  Yelp
//
//  Created by Yat Choi on 5/24/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit

protocol RadioCellDelegate: class {
  func onButtonTapped(radioCell: RadioCell)
}

class RadioCell: UITableViewCell {

  @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var optionLabel: UILabel!
  @IBOutlet weak var buttonView: UIView!
  @IBOutlet weak var mainButton: UIButton!
  
  var delegate:RadioCellDelegate?
  
  func initializeCell(delegate:RadioCellDelegate, name:String, isSet: Bool) {
    self.delegate = delegate
    self.optionLabel.text = name
    if (isSet) {
      mainButton.setImage(UIImage(named:"RadioSelected"), forState: .Normal)
    } else {
      mainButton.setImage(UIImage(named:"RadioUnselected"), forState: .Normal)
    }
    
    let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(RadioCell.onCellTapped(_:)))
    tapRecognizer.numberOfTapsRequired = 1
    cellView.userInteractionEnabled = true
    cellView.addGestureRecognizer(tapRecognizer)
  }
  
  func onCellTapped(sender: UITapGestureRecognizer) {
    self.delegate?.onButtonTapped(self)
  }
  
  @IBAction func mainButtonTapped(sender: AnyObject) {
    self.delegate?.onButtonTapped(self)
  }
}
