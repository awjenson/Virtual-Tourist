//
//  CoreDataPhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 12/12/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

/* Two Extensions are below this class (at the bottom of this file):
 1. MKMapViewDelegate
 2. UICollectionViewDelegateFlowLayout
*/

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    fileprivate let flickr = Flickr()

    // Collection View Flow 
    let itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50, right: 20.0)

    var photosSelected = false

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")

    // Pin
    var pinSelected: Pin? = nil

    // Photos
    // Initalize a Photo array that contain properties (image and imageURL). We will load data into this blank array from the fetchedResultController.
    var photos: [Photo] = [Photo]()
    var selectedIndexPath = [IndexPath]()


    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the DataSource and Delegate to the CollectionView Outliet
        collectionView.delegate = self
        collectionView.dataSource = self

        mapView.delegate = self
        setupMapAndDropPin()

        // Core Data setup for select Pin/Photos
        fetchPhotos()
    }


    // MARK: - Map Methods

    // Drop a pin at selected location
    // Needs to display selected Pin (via passing data with segue)
    func setupMapAndDropPin() {

        mapView.addAnnotation(pinSelected!)
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: pinSelected!.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }


    // MARK: Collection View - DataSource Protocol Methods

    // The number of items in a section is the count of the photos array from the selectedPin object (see PhotoAlbumViewController).
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        //        return pinPassedOver.searchResults.count
        print("Photos count in Collection View: \(photos.count)")
        return photos.count
    }

    // ************ This is a unique method when it comes to Core Data
    // once you have the URL for a photo you will need to download and display it inside the imageView for each cell.
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "FlickrCell", for: indexPath) as! PhotoAlbumCollectionViewCell

        // set 'photo' to 'indexPath.row' which is the current item object that is selected.
        // creating the 'photo' property reduces the need to type photos[indexPath.row] multiple times.
        let photo = photos[indexPath.row]
        let photoUrlString = photo.imageURL
        cell.imageView.image = UIImage(named: "defaultImage")

        // GET imageData: NSData

        // Check if there is existing NSData (image) for Photo Entity in Database
        //     NSData    : Photo.data
        if let imageData = photo.image {

            let image = UIImage(data: imageData as Data)
            cell.imageView.image = image
            cell.activityIndicator.stopAnimating()

        } else {
            // We should enter here after clicking the Refresh Images Button to get image URLs, now we need to convert the 20 image URLs to 20 NSData objects that will convert into 20 Collection View Images"

            // Display default image and start animating
            cell.imageView.image = UIImage(named: "defaultImage")
            cell.activityIndicator.startAnimating()

            // Goal in closure is to return NSData that can be converted into UIImage
            flickr.getDataFromUrlString(photoUrlString!, { (imageData, error) in

                guard let image = UIImage(data: imageData!) else {

                    print("Error loading image in cellForItemAt: getDataFromUrlString: unable to get imageData from photoUrlString, \(String(describing: error?.debugDescription))")
                    return
                }

                // imageData (NSData) was successfully returned

                    performUIUpdatesOnMain({
                        // Save to Core Data
                        photo.image = imageData! as NSData
                        delegate.stack.save()

                        // Display new images in Collection View
                        cell.activityIndicator.stopAnimating()
                        cell.imageView.image = image
                    })
            })
        }
        return cell
    }

    // Rubric: Once all images have been downloaded, can the user remove photos from the album by tapping the image in the collection view.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let photo = photos[indexPath.row]
        // delete photo from collectionView and Core Data
        photos.remove(at: indexPath.row)
        context.delete(photo)
        delegate.stack.save()
        // reload collection view everytime an item is selected
        collectionView.reloadData()
    }

    func removeSelectedPhotos() {
        if selectedIndexPath.count > 0 {
            for indexPath in selectedIndexPath {
                let photo = photos[indexPath.row]
                context.delete(photo)
                self.photos.remove(at: indexPath.row)
                self.collectionView.deleteItems(at: [indexPath as IndexPath])
                print("photo at row \(indexPath.row) deleted from Core Data and Collection View")
            }
            delegate.stack.save()
        }
        selectedIndexPath = [IndexPath]()
    }


    // MARK: - Core Data (And Flickr API) Methods

    func fetchPhotos() {

        // Check if photos [Photo] (Photo array) data exist for the selected pin in Core Data
        // fetchRequest -> Photo, pin (if photos exist on selected pin)
        // reload collectionView
        // If not, then call Flickr API Network Request

        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = []
        // "pin" is located in DataModel.xcdatamodelId > Photo Entity > Relationships
        // "%@" refers to pinSelected
        fetchRequest.predicate = NSPredicate(format: "pin = %@", pinSelected!)
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        do {
            try fetchedResultController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }

        if let data = fetchedResultController.fetchedObjects, data.count > 0 {

            // save (add) data to photos property created above
            photos = data
            self.collectionView.reloadData()
        } else {
            // No photo data, call a new flickr API network request
            getPhotosFromFlickr(pinSelected!)
        }

    }

    // This method is called in loadNewPhotosAndSaveToCoreData() in order to delete existing photos before downloading new photos.
    func deleteAllPhotos() {
        print("Deleting all photos")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pinSelected!)

        do {
            let photos = try context.fetch(fetchRequest) as! [Photo]
            for photo in photos {
                // delete NSManagedObject
                context.delete(photo)
            }
        } catch {
            print("deleteAllPhotos: Error deleting photo")
        }
    }

    func getPhotosFromFlickr(_ pinSelected: Pin) {

        loadNewPhotosAndSaveToCoreData()
        collectionView.reloadData()
    }

    // Setup FetchResult, Predicate, and FetchResultController
    func setupFetchResultWithPredicateAndFetchResultController() {

        // not necessary to sort photos, but I did it anyway since this is what Udacity's Cool Notes app did.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imageURL", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin = %@", self.pinSelected!)
    }

    // Fetch Photos (Includes Flickr API Network Request)
    func loadMoreUrlStringsForPhotos() {

        var photoCoreData: Photo?

        guard let pinSelected = pinSelected else {
            print("loadMoreUrlStringsForPhotos: pinSelected is nil")
            return
        }

        // **** Cordinates Saved, Begin Flickr API Request
        flickr.searchFlickrForCoordinates(pin: pinSelected) { (arrayOfImageUrlStrings, errorString) in

            print("Running network request on the main thread? (It should be false b/c inside searchFlickrForCoordinates closure): \(Thread.isMainThread)")

            /* GUARD: Was there an error? */
            guard (arrayOfImageUrlStrings != nil) else {
                // Error...
                // display the errorString using createAlert
                // The app gracefully handles a failure to download student locations.
                print("Unsuccessful in obtaining photos of selected location from Flickr: \(String(describing: errorString))")

                performUIUpdatesOnMain {
                    // Display error to the user
                    self.createAlert(title: "Error", message: "Failure to download photos of location.")
                }
                return
            }

            print("Successfully obtained Photos (arrayOfImageUrlStrings) from Flickr. Send to Context to be stored in Photo's imageURL attribute.")

            // Take 'arrayOfImageUrlStrings' and implement for-loop to save to context on the main thread.
            performUIUpdatesOnMain {

                for imageUrlString in arrayOfImageUrlStrings! {

                    if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {

                        photoCoreData = Photo(entity: entity, insertInto: context)
                        photoCoreData?.imageURL = imageUrlString[Constants.FlickrParameterValues.MediumURL] as? String
                        photoCoreData?.pin = self.pinSelected!
                    }
                }

                // save new url strings to stack
                delegate.stack.save()

                print("loadMoreUrlStringsForPhotos(): Photos updated, re-call fetchPhotos() to update collection view")
                self.fetchPhotos()

            } // End of performUIUpdatesOnMain
            return
        } // End of Flickr Closure

    }

    func loadNewPhotosAndSaveToCoreData() {

        // First, delete existing photos
        photos.removeAll()

        // Save Core Data after all photos have been deleted
        delegate.stack.save()
        // Flick API Network Request

        // Second, download new photos

        /// **** Flickr Network Request ****

        // Coordinates contain a value, save them to Constant file properties to use in Flickr API photos search

        // Cordinates Saved, Begin Flickr API Request
        // **** Cordinates Saved, Begin Flickr API Request
        flickr.searchFlickrForCoordinates(pin: pinSelected!) { (arrayOfImageUrlStrings, errorString) in

            print("Running network request on the main thread? (It should be false b/c inside searchFlickrForCoordinates closure): \(Thread.isMainThread)")

            /* GUARD: Was there an error? */
            guard (arrayOfImageUrlStrings != nil) else {
                // Error...
                // display the errorString using createAlert
                // The app gracefully handles a failure to download student locations.
                print("Unsuccessful in obtaining photos of selected location from Flickr: \(String(describing: errorString))")

                performUIUpdatesOnMain {
                    // Display error to the user
                    self.createAlert(title: "Error", message: "Failure to download photos of location.")
                }
                return
            }

            // 'results' are an array of [[String: Any]]?
            print("Successfully obtained Photos' results [[String: Any]]? from Flickr: \(arrayOfImageUrlStrings!)")

            performUIUpdatesOnMain {

                var photoCoreData: Photo?

                // **** Core Data: Add web URLs and Pin(s) only at this point...
                if photoCoreData == nil {

                    for photo in arrayOfImageUrlStrings! {
                        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
                            photoCoreData = Photo(entity: entity, insertInto: context)
                            photoCoreData?.imageURL = photo[Constants.FlickrParameterValues.MediumURL] as? String
                            photoCoreData?.pin = self.pinSelected
                        }
                    }
                }

                // Rubric: When pins are dropped on the map, the pins are persisted as Pin instances in Core Data and the context is saved.
                delegate.stack.save()
                print("Running network request on the main thread? (It should be true b/c inside performUIUpdatesOnMain): \(Thread.isMainThread). Reload Collection View.")
                self.collectionView.reloadData()

                print("Inside func loadNewPhotosAndSaveToCoreData(): reload complete, refresh collection view")
                print("Inside func loadNewPhotosAndSaveToCoreData(): Are photo.imageURL (String) nil?: \(String(describing: photoCoreData?.imageURL))")
            } // performUIUpdatesOnMain
            return
        } // End of Flickr Closure
    }


    // MARK: - IB Action Methods

    @IBAction func refreshImagesButtonTapped(_ sender: UIButton) {

        print("Refresh Button Tapped.")

        // First, delete all existing photos from context
        for photo in photos {
            context.delete(photo)
        }

        // Start over with an empty array of type Photo
        photos = [Photo]()

        collectionView.reloadData()

        // load new photos (a new fetchRequest is called at the end of loadMoreUrlStringsForPhotos())
        loadMoreUrlStringsForPhotos()
    }

} // *** End of PhotoAlbumViewController Class ***



extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let myPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PinAnnotationIdentifier")
        myPinView.animatesDrop = true
        myPinView.annotation = annotation

        return myPinView
    }
}

// ******************************************

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    // From Ray Wenderlich Tutorials on Collection Views...
    // Collection View Layout

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

