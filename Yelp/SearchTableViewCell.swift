//
//  SearchTableViewCell.swift
//  Yelp
//
//  Created by Yat Choi on 5/23/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit
import AFNetworking

class SearchTableViewCell: UITableViewCell {

  @IBOutlet weak var searchImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var ratingImage: UIImageView!
  @IBOutlet weak var reviewsLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var categoriesLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }
  
  func populateCellWithBusiness(business: Business) {
    if let name = business.name {
      self.nameLabel.text = name
    }
    
    if let distance = business.distance {
      self.distanceLabel.text = distance
    }
    
    if let reviewCount = business.reviewCount {
      self.reviewsLabel.text = "\(reviewCount) Reviews"
    }
    
    if let location = business.address {
      self.locationLabel.text = location
    }
    
    if let categories = business.categories {
      self.categoriesLabel.text = categories
    }
    
    if let mainImage = business.imageURL {
      self.searchImageView.setImageWithURL(mainImage)
    }
    
    if let ratingImage = business.ratingImageURL {
      self.ratingImage.setImageWithURL(ratingImage)
    }
  }
    
}
