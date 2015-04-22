//
//  FlickrPhotosViewController.swift
//  FlickrSearch
//
//  Created by Ryan on 2015/4/21.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit


class FlickrPhotosViewController: UICollectionViewController {

  private let reuseIdenifier = "FlickrCell"
  // 決定每個section 內部的範圍
  private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
  // "searches" is an array that will keep track of all the searches made in the app.
  private var searches = [FlickrSearchResults]()
  // "flicker" is a reference to the object that will do the searching for you.
  private let flickr = Flickr()
  
  // "photoForIndexPath" is a convenience method that will get a specific photo related to an index path in your collection view.You're going to access a aphoto for a specific index path a lot, and you don't want to repeat code.
  func photoForIndexPath(indexPath: NSIndexPath) -> FlickrPhoto {

    return searches[indexPath.section].searchResults[indexPath.row]
  }
  
  
//  override func viewDidLoad() {
//    self.view.backgroundColor = UIColor.whiteColor()
//  }
  
}



extension FlickrPhotosViewController: UITextFieldDelegate {

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    // 1 After adding an activity view, use the Flicr wrapper class i provided to search Flickr for photots that match the given search term asnchronously. When the search completes, the completion block will be called with the result set of FlickrPhoto objects, and an error (if there was one)
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    // TODO: ??????
    view.addSubview(activityIndicator)
    activityIndicator.frame = textField.bounds
    //activityIndicator.center = CGPoint(x: textField.bounds.origin.x + textField.bounds.size.width/2, y: textField.bounds.origin.y + textField.bounds.size.height/2)
    activityIndicator.startAnimating()
    flickr.searchFlickrForTerm(textField.text) {
      results, error in
      
      
      // 2 Log any errors to console. Obsviosly, in a production application you would want to display these errors to the user.
      activityIndicator.removeFromSuperview()
      if error != nil {
        println("Error searching : \(error)")
      }
      
      if results != nil {
        // 3 the results get logged and added to the front of the searches array
        println("Found \(results!.searchResults.count) matching \(results!.searchTerm)")
        self.searches.insert(results!, atIndex: 0)

 
        
        // 4 At this stage, you have new data and need to refresh the UI. You're using the insertSections method to add your results at the top of the list.
        self.collectionView?.reloadData()
        
      }
    }
    
    //textField.text = nil
    textField.resignFirstResponder()
    return true
    
  }
}


extension FlickrPhotosViewController: UICollectionViewDataSource {
  
  // 1. There's one search per section
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    
    return searches.count
  }
  
  // 2. The number of items in a section is the count of the searchResults array from the relevant FlickrSearch object
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return searches[section].searchResults.count
  }
  
  // 3. Reuse teh cell
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdenifier, forIndexPath: indexPath) as! FlickrPhotoCell
    
    let flickrPhoto = photoForIndexPath(indexPath)
    cell.backgroundColor = UIColor.blackColor()
    
    cell.imageView.image = flickrPhoto.thumbnail
    
    return cell
  }
  
}

// it allows you to tweak the behaviour of the layout, configuring things like the cell spacing, scroll direction, and more.
extension FlickrPhotosViewController: UICollectionViewDelegateFlowLayout {
  
  // 1. This method is responsible for telling the layout the size of a given cell. you must first determine which FlickrPhoto you are lookin at, since each photo could have different dimensions.
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    
    let flickrPhoto = photoForIndexPath(indexPath)
    
    // 2 If thumbnail is not exist, the default size is returned
    if var size = flickrPhoto.thumbnail?.size {
      size.width += 10
      size.height += 10
      return size
    }
    
    return CGSize(width: 100, height: 100)
  }
  
  // 3. Return the spacing between the cells, headers, and footers
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    
    return sectionInsets
  }
}



