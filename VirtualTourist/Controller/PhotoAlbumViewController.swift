//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 12/12/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

// Source:
// https://guides.codepath.com/ios/Using-UICollectionView
// https://www.journaldev.com/10678/ios-uicollectionview-example-tutorial


import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!


    // MARK: - Properties

    fileprivate let reuseIdentifier = "FlickrCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50, right: 20.0)

    // flickr - a reference to the object that will do the searching for you
    fileprivate var photos = arrayOfPhotos
    fileprivate let itemsPerRow: CGFloat = 3

    // Allow for multiple photo selection
    // selectedPhotos: array that will keep track of the photos the user has selected
    fileprivate var selectedPhotos = [FlickrPhoto]()
    // shareTextLabel: will provide feedback to the user on how many photos have been selected
    fileprivate let shareTextLabel = UILabel()

    fileprivate var searches = [FlickrSearchResults]()

    // set selected pin location
    let initialLocation = CLLocation(latitude: Constants.SelectedPin.latitude, longitude: Constants.SelectedPin.longitude)

    // The location argument is the center point. The region will have north-south and east-west spans based on a distance of regionRadius.
    let regionRadius: CLLocationDistance = 10000

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        // setRegion(_:animated:) tells mapView to display the region.
        mapView.setRegion(coordinateRegion, animated: true)

        dropPin()
    }

    // Drop a pin at selected location
    func dropPin() {
        let pinAnnotation: MKPointAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = CLLocationCoordinate2DMake(Constants.SelectedPin.latitude, Constants.SelectedPin.longitude)
        mapView.addAnnotation(pinAnnotation)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the DataSource and Delegate to the CollectionView Outliet
        collectionView.delegate = self
        collectionView.dataSource = self

//        mapView.delegate = self

        // call the helper method to zoom into initialLocation at load
        centerMapOnLocation(location: initialLocation)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}


// MARK: - Private


// ********************************
// MARK: - UICollectionViewDelegate
extension PhotoAlbumViewController: UICollectionViewDelegate {

    
}

// **********************************
// MARK: - UICollectionViewDataSource
extension PhotoAlbumViewController: UICollectionViewDataSource {

    // 1
    // There's one search per section, so the number of sections is the count of the searches array
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // 2
    // The number of items in a section is the count of the searchResults array from the relevant FlickrSearch object
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {

        return 20

//        if searches[section].searchResults.count < 20 {
//            return searches[section].searchResults.count
//        } else {
//            return 20
//        }
    }

    //3
    // This is a placeholder method just to return a blank cell - you'll be populating it later. Note that collection views require you to have registered a cell with a reuse identifier, or a runtime error will occur.
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // 1
        // The cell coming back is FlickPhotoCellectionViewCell
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell


        cell.backgroundColor = UIColor.white

        // 3
        // You populate the image view with the thumbnail
        // cell.imageView.image = flickrPhoto.thumbnail

        // configure the cell
        return cell
    }

    // custom function to generate a random UIColor
    func randomColor() -> UIColor{
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }



    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        var sourceResults = searches[(sourceIndexPath as NSIndexPath).section].searchResults
        let flickrPhoto = sourceResults.remove(at: (sourceIndexPath as NSIndexPath).row)

        var destinationResults = searches[(destinationIndexPath as NSIndexPath).section].searchResults
        destinationResults.insert(flickrPhoto, at: (destinationIndexPath as NSIndexPath).row)
    }

}


// ******************************************
// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    // 1
    // This is responsible for telling the layout the size of a given cell.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 2
        // Here you work out the total amount of space taken up by padding. There will be n + 1 evenly sized spaces, where n is the number of items in the row. The space size can be taken from the left section inset. Subtracting this from the view's width and dividing by the number of items in a row gives you the width for each item. You then return the size as a square.
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    // 3
    // Returns the spacing between the cells, headers, and footers. A constant is used to store the value.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    // 4
    // This method controls the spacing between each line in the layout. You want this to match the padding at the left and right.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


// ***************************************************************




