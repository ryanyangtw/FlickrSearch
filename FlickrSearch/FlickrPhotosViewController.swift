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
  
  // For Multiple selection
  private var selectedPhotos = [FlickrPhoto]()
  private var shareTextLabel = UILabel()
  
  
  
  // 1. largePhotoIndexPath is an optional that will hold the index path of the tapped photo, if there is one.
  var largePhotoIndexPath: NSIndexPath? {
    didSet {
      
      // 2. Whenever this propery gets updated, the collection view needs to be updated, a didSet property observer is the safest place to manage this. There may be two cells that need reloading, if the user has tapped one cell then another, or just one if the user has tapped the first cell, then tapped it again to shrink.
      var indexPaths = [NSIndexPath]()
      if largePhotoIndexPath != nil {
        indexPaths.append(largePhotoIndexPath!)
      }
      if oldValue != nil {
        indexPaths.append(oldValue!)
      }
      
      // 3. performBatchUpdates will animate an changes to the collection view performed inside the block. You want it to reload the affected cells. The return statement is there because a single-statement
      collectionView?.performBatchUpdates({
        self.collectionView?.reloadItemsAtIndexPaths(indexPaths)
        return
        }, completion: {
          completed in
          
          // 4. Once the animated update has finished, it's a nice touch to scroll the enlarged cell to the middle of the screen // 將手機畫面移動到該圖片
          if self.largePhotoIndexPath != nil {
            self.collectionView?.scrollToItemAtIndexPath(self.largePhotoIndexPath!, atScrollPosition: .CenteredVertically, animated: true)
          }
          
      })
    }
  }
  
  
  var sharing: Bool = false {
  
    didSet {
      collectionView?.allowsMultipleSelection = sharing
      
      // 每次更新sharing時議定會先把所有cell deselected
      collectionView?.selectItemAtIndexPath(nil, animated: true, scrollPosition: .None)
      selectedPhotos.removeAll(keepCapacity: false)
      
      if sharing && largePhotoIndexPath != nil {
        largePhotoIndexPath = nil
      }
      
      let shareButton = self.navigationItem.rightBarButtonItems!.first as! UIBarButtonItem
      
      if sharing {
        updateSharedPhotoCount()
        let sharingDetailItem = UIBarButtonItem(customView: shareTextLabel)
        navigationItem.setRightBarButtonItems([shareButton, sharingDetailItem], animated: true)
      } else {
        navigationItem.setRightBarButtonItems([shareButton], animated: true)
      }
      
      
      
    }
  }
  
  
  // "photoForIndexPath" is a convenience method that will get a specific photo related to an index path in your collection view.You're going to access a aphoto for a specific index path a lot, and you don't want to repeat code.
  func photoForIndexPath(indexPath: NSIndexPath) -> FlickrPhoto {

    return searches[indexPath.section].searchResults[indexPath.row]
  }
  
  func updateSharedPhotoCount() {
    shareTextLabel.textColor = themeColor
    shareTextLabel.text = "\(selectedPhotos.count) photos selected"
    shareTextLabel.sizeToFit()
  }

  

//MARK: - IBAction
  @IBAction func share(sender: AnyObject) {
    
    if searches.isEmpty {
      return
    }
    
    if !selectedPhotos.isEmpty {
      var imageArray = [UIImage]()
      for photo in self.selectedPhotos {
        imageArray.append(photo.thumbnail!)
      }
      
      let shareScreen = UIActivityViewController(activityItems: imageArray, applicationActivities: nil)
      
      // can't run on mobile devise
      let popover = UIPopoverController(contentViewController: shareScreen)
      popover.presentPopoverFromBarButtonItem(self.navigationItem.rightBarButtonItems!.first as! UIBarButtonItem, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
      
    }
    
    sharing = !sharing
    
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
    //cell.backgroundColor = UIColor.blackColor()
    //cell.imageView.image = flickrPhoto.thumbnail
    
    // 1. Always stop the activity spinner - you could be reusing a cell that was previously loading an image
    cell.activityIndicator.stopAnimating()
    
    // 2. if you're not looking at the large photo, just set the thumnbail and return
    if indexPath != largePhotoIndexPath {
      cell.imageView.image = flickrPhoto.thumbnail
      return cell
    }
    
    // 3. if the large image is already loaded, set it and return
    if flickrPhoto.largeImage != nil {
      cell.imageView.image = flickrPhoto.largeImage
      return cell
    }
    
    // 4. By this point, you want the large image, but it doesn't exist yet, Set the thumnail image and start the spinner going. The thumbnail will stretch until the download is complete
    cell.imageView.image = flickrPhoto.thumbnail
    cell.activityIndicator.startAnimating()
    
    // 5. Ask for the large image from Flickr. This loads the image asynchronously and has a completion block
    flickrPhoto.loadLargeImage() {
      loadedFlickrPhoto, error in
      
      // 6. The load has finished, so stop the spinner
      cell.activityIndicator.stopAnimating()
      
      // 7. if there was an error or no photo was loaded, there's not much you can do
      if error != nil {
        return
      }
      
      if loadedFlickrPhoto.largeImage == nil {
        return
      }
      
      // 8. Check that the large photo index path hasn't changed while the download was happening, and retrieve whatever cell is crrently in use for that index path (it may not be the original cell, since scrolling could have happened) and set the large image.
      if indexPath == self.largePhotoIndexPath {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FlickrPhotoCell {
          cell.imageView.image = loadedFlickrPhoto.largeImage
        }
      }
    
    }
    
    
    return cell
  }
  
  // 有在 UICollectionView 的 Accessory 勾選 header 或 footer 才會呼叫此method
  // This mehod is similar to cellForItemAtIndexPath, but for supplementary views
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    
    // 1. the kind parameter is supplied by the layout object indicates which sort of supplementary view is being asked for
    switch kind {
      
      // 2. UICollectionElmentKindSectionHeader is a supplementary view kind belonging to the flow layout. By checking that box in the storyboard to add a section header, you told the flow layout that it needs to start asking for these views. There is also a UICollectionElementKindSectionFooter, which you're not currently usinf. If you don't use the flow layout, you don't get header and footer views for free like this.
      case UICollectionElementKindSectionHeader:
        
        // 3. The header view is dequeued using the identifier added in the storyboard. This works just like cell dequeuing, The Label's text is then set to the relevant search term.
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "FlickrPhotoHeaderView", forIndexPath: indexPath) as! FlickrPhotoHeaderView
        
        headerView.label.text = searches[indexPath.section].searchTerm
          return headerView
      
      default:
        // 4. An assert is placed here to make it clear to other developer (including future you!) that you're not expecting to be asked for anything other than a header view.
        assert(false, "Unexpected element kind")
    }
    
  }
  
}

// it allows you to tweak the behaviour of the layout, configuring things like the cell spacing, scroll direction, and more.
extension FlickrPhotosViewController: UICollectionViewDelegateFlowLayout {
  
  // 1. This method is responsible for telling the layout the size of a given cell. you must first determine which FlickrPhoto you are lookin at, since each photo could have different dimensions.
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    
    let flickrPhoto = photoForIndexPath(indexPath)
    
    // New code
//    if indexPath == largePhotoIndexPath {
//      var size = collectionView.bounds.size
//      size.height -= topLayoutGuide.length
//      size.height -= (sectionInsets.top + sectionInsets.right)
//      size.width -= (sectionInsets.left + sectionInsets.right)
//      return flickrPhoto.sizeToFillWidthOfSize(size)
//    }
    
    if indexPath == largePhotoIndexPath {
      var size = collectionView.bounds.size
      // topLayoutGuide.length = 64 (status bar:20 + nav bar: 44)
      size.height -= topLayoutGuide.length
      //println("topLayoutGuide.length: \(topLayoutGuide.length)")
      size.height -= (sectionInsets.top + sectionInsets.bottom)
      size.width -= (sectionInsets.left + sectionInsets.right)
      return flickrPhoto.sizeToFillWidthOfSize(size)
    }
    
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


extension FlickrPhotosViewController: UICollectionViewDelegate {
  
  override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    
    if sharing {
      return true
    }
    
    
    
    if largePhotoIndexPath == indexPath {
      largePhotoIndexPath = nil
    } else {
      largePhotoIndexPath = indexPath
    }
    
    return false
  }
  
  
  
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
  
    if sharing {
      let photo = photoForIndexPath(indexPath)
      selectedPhotos.append(photo)
      updateSharedPhotoCount()
    }
  
  }
  
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    
    if sharing {
      if let foundIndex = find(selectedPhotos, photoForIndexPath(indexPath)) {
        selectedPhotos.removeAtIndex(foundIndex)
        updateSharedPhotoCount()
      }
    }
  }

}




