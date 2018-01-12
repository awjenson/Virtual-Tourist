//
//  CoreDataPhotoAlbumViewController.swift
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
import CoreData

/* PhotoAlbumViewController conforms to multiple protocols (see below):
    (1) UICollectionViewDelegate,
    (2) UICollectionViewDataSource,
    (3) UICollectionViewDelegateFlowLayout,
    (4) NSFetchedResultsControllerDelegate,
    (5) MKMapViewDelegate
 */



// See CoreDataViewController for Collection View Methods

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!


    // MARK: - Properties
    fileprivate let flickr = Flickr()
//    fileprivate var searches = [FlickrSearchResults]()


    // Collection View Flow 
    let itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50, right: 20.0)


    // searches is an array that will keep track of all the searches made in the app
    // Core Data Stack
    var stack: CoreDataStack?
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")

    // Pin
    var pinSelected: Pin? = nil
//    var selectedPinLocation = CLLocationCoordinate2D()

    // Photos
    var photos: [Photo] = [Photo]() // Photo array
    var selectedIndex = [IndexPath]()


    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the DataSource and Delegate to the CollectionView Outliet
        collectionView.delegate = self
        collectionView.dataSource = self

        mapView.delegate = self
        setupMapAndDropPin()

        // Core Data setup for select Pin/Photos
        setupFetchResultWithPredicateAndFetchResultController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        // Fetch photos from selected pin
        photos = photosFetchRequest()
    }


    // MARK: - Methods

    // Drop a pin at selected location
    // Needs to display selected Pin (via passing data with segue)
    func setupMapAndDropPin() {

        mapView.addAnnotation(pinSelected!)
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: pinSelected!.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }




    // Setup FetchResult, Predicate, and FetchResultController
    func setupFetchResultWithPredicateAndFetchResultController() {

//        // Similar to Udacity's Cool Notes, Create (1) FetchRequest and (2) FetchRequestController in viewDidLoad of the PhotoAlbumViewController
//        // (1/2) Create a fetchrequest
//        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
//        // Udacity comment: "So far we have a search that will match ALL notes. However, we're only interested in those within the selected Photo data: NSPredicate to the rescue!"
//        // For (format: "pin = %", pinSelected!), "pin" is from the the Relationships section of the Photo Entity. And "pinSelected!" is the specific Pin (Entity) that was selected.
//        fr.predicate = NSPredicate(format: "pin = %@", pinSelected!)
//        fr.sortDescriptors = [NSSortDescriptor(key: "imageURL", ascending: true)]
//
//        // (2/2) Create the FetchedResultsController
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: (stack!.context), sectionNameKeyPath: nil, cacheName: nil)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imageURL", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pinSelected!)
    }


    func photosFetchRequest() -> [Photo] {

        do {
            print("photosFetchRequest(): Trying to fetch photos")
            return try stack!.context.fetch(fetchRequest) as! [Photo]

        } catch {
            print("There was an error fetching the photos from the selected pin")
            return [Photo]()
        }
    }


    // MARK: Collection View - DataSource Protocol Methods

    // 1
    // There's one search per section, so the number of sections is the count of the searches array
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // 2
    // The number of items in a section is the count of the photos array from the selectedPin object (see PhotoAlbumViewController).
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        //        return pinPassedOver.searchResults.count
        return photos.count
    }

    //3
    // ************ This is a unique method when it comes to Core Data
    // This is a placeholder method just to return a blank cell – you’ll be populating it later. Note that collection views require you to have registered a cell with a reuse identifier, or a runtime error will occur.
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "FlickrCell", for: indexPath) as! PhotoAlbumCollectionViewCell

        // Inital setup to display images
        cell.imageView.image = UIImage(named: "defaultImage")
        cell.activityIndicator.startAnimating()

        // Check if photo already exists in Core Data
        if let photo = self.photos[indexPath.item].image {
            print("cellForItemAt indexPath: Photo already exists, loading from Core Data")

            // Load on main queue
            DispatchQueue.main.async {
                if let image = UIImage(data: photo as Data) {
                    cell.imageView.image = image
                    // Stop animating activityIndicator
                    cell.activityIndicator.stopAnimating()
                }
            }
        } else {
            // photo does not already exist, download from Flickr API
            print("cellForItemAt indexPath: Photo does NOT already exist, loading from Flickr API")
            loadNewPhotosAndSaveToCoreData()
        }

        // configure the cell
        return cell
    }

    // Rubric: Once all images have been downloaded, can the user remove photos from the album by tapping the image in the collection view.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let photo = photos[indexPath.row]
        stack?.context.delete(photo)
        photos.remove(at: indexPath.row)
        collectionView.reloadData()
    }



















    // MARK: - IB Action Methods

    @IBAction func refreshImagesButtonTapped(_ sender: UIButton) {

        loadNewPhotosAndSaveToCoreData()

    }

    // MARK: - Methods

    func loadNewPhotosAndSaveToCoreData() {

        // First, delete existing photos
        deleteAllPhotos()

        // Second, download new photos

        /// **** Flickr Network Request ****

        // Coordinates contain a value, save them to Constant file properties to use in Flickr API photos search

        // Cordinates Saved, Begin Flickr API Request
        // **** Cordinates Saved, Begin Flickr API Request
        flickr.searchFlickrForCoordinates(pin: pinSelected!) { (results, errorString) in

            print("Running network request on the main thread? (It should be false b/c inside searchFlickrForCoordinates closure): \(Thread.isMainThread)")

            /* GUARD: Was there an error? */
            guard (results != nil) else {
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

            print("Successfully obtained Photos from Flickr")

            performUIUpdatesOnMain {

                var photoTemp: Photo?

                print("recognizeLongPress(): Get photos for selected pin.")

                // **** Core Data: Add web URLs and Pin(s) only at this point...
                if photoTemp == nil {
                    for photo in results! {
                        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: (self.stack?.context)!) {
                            photoTemp = Photo(entity: entity, insertInto: (self.stack?.context)!)
                            photoTemp?.imageURL = photo[Constants.FlickrParameterValues.MediumURL] as? String
                            photoTemp?.pin = self.pinSelected
                        }
                    }
                }
                print("reload complete")
                // Rubric: When pins are dropped on the map, the pins are persisted as Pin instances in Core Data and the context is saved.
                self.stack?.save()

                // reload images on collection view
                self.collectionView.reloadData()
            }
            return
        } // End of Flickr Closure
    }


    // This method is called in loadNewPhotosAndSaveToCoreData() in order to delete existing photos before downloading new photos.
    func deleteAllPhotos() {
        print("Deleting all photos")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pinSelected!)

        do {
            let photos = try stack?.context.fetch(fetchRequest) as! [Photo]
            for photo in photos {
                // delete NSManagedObject
                stack?.context.delete(photo)
            }
        } catch {
                print("deleteAllPhotos: Error deleting photo")
        }

    }

} // End of Class PhotoAlbumViewController


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














