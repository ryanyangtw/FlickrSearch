//
//  FlickrPhotoCell.swift
//  FlickrSearch
//
//  Created by Ryan on 2015/4/22.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class FlickrPhotoCell: UICollectionViewCell {
  
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  override var selected: Bool {
    didSet {
      self.backgroundColor = selected ? themeColor : UIColor.blackColor()
    }
  }
  
  override func awakeFromNib() {
    // TODO: ???
    super.awakeFromNib()
    self.selected = false
  }

  
}
