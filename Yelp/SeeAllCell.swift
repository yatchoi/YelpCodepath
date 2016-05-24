//
//  SeeAllCell.swift
//  Yelp
//
//  Created by Yat Choi on 5/23/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit

protocol SeeAllCellDelegate: class {
  func onSeeAllTapped(seeAllCell: SeeAllCell)
}

class SeeAllCell: UITableViewCell {
  
  var delegate: SeeAllCellDelegate?
  @IBAction func seeAllTapped(sender: AnyObject) {
    delegate?.onSeeAllTapped(self)
  }
}
