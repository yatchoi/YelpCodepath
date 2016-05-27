//
//  DealCell.swift
//  Yelp
//
//  Created by Yat Choi on 5/23/16.
//  Copyright © 2016 yatchoi. All rights reserved.
//

import UIKit
import SevenSwitch

protocol DealCellDelegate: class {
  func dealCell(switchCell: DealCell, didUpdateValue: Bool)
}

class DealCell: UITableViewCell {
  
  @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var bgView: UIView!
  
  var delegate: DealCellDelegate?
  var sevenSwitch: SevenSwitch!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    sevenSwitch = SevenSwitch(frame: .zero)
    bgView.addSubview(sevenSwitch)
    sevenSwitch.translatesAutoresizingMaskIntoConstraints = false
    sevenSwitch.thumbImage = scaleImage(UIImage(named: "YelpIcon")!, toSize: CGSize(width: 10, height: 10))
    
    let trailing = NSLayoutConstraint(item: sevenSwitch, attribute: .Trailing, relatedBy: .Equal, toItem: bgView, attribute: .Trailing, multiplier: 1, constant: -7)
    let centerY = NSLayoutConstraint.init(item: sevenSwitch, attribute: .CenterY, relatedBy: .Equal, toItem: bgView, attribute: .Leading, multiplier: 1, constant: 22)
    let height = NSLayoutConstraint.init(item: sevenSwitch, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30)
    let width = NSLayoutConstraint.init(item: sevenSwitch, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 50)
    bgView.addConstraint(trailing)
    bgView.addConstraint(centerY)
    NSLayoutConstraint.activateConstraints([height, width])
    
    sevenSwitch.addTarget(self, action: "switchChanged:", forControlEvents: UIControlEvents.ValueChanged)
  }
  
  func populateSwitchCell(delegate: DealCellDelegate, isSet:Bool) {
    self.delegate = delegate
    sevenSwitch.on = isSet
    
    let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(DealCell.onCellTapped(_:)))
    tapRecognizer.numberOfTapsRequired = 1
    cellView.userInteractionEnabled = true
    cellView.addGestureRecognizer(tapRecognizer)
  }
  
  func onCellTapped(sender: UITapGestureRecognizer) {
    sevenSwitch.on = !sevenSwitch.on
    self.delegate?.dealCell(self, didUpdateValue: sevenSwitch.on)
  }
  
  func scaleImage(image: UIImage, toSize newSize: CGSize) -> (UIImage) {
    let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
    let context = UIGraphicsGetCurrentContext()
    CGContextSetInterpolationQuality(context, .High)
    let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
    CGContextConcatCTM(context, flipVertical)
    CGContextDrawImage(context, newRect, image.CGImage)
    let newImage = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
    UIGraphicsEndImageContext()
    return newImage
  }
}
