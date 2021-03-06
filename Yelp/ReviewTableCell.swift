//
//  ReviewTableCell.swift
//  Yelp
//
//  Created by Yat Choi on 5/26/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit

class ReviewTableCell: UITableViewCell {
  var review: Review!
  
  @IBOutlet weak var profilePicView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var excerptLabel: UILabel!
  
  func initializeCell(review: Review) {
    self.review = review
    profilePicView.af_setImageWithURL(review.userImageURL!)
    usernameLabel.text = review.username!
    excerptLabel.text = review.excerpt!
  }
}
