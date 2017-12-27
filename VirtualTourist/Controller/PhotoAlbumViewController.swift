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
    (4) NSFetchedResultsControllerDelegate
 */
class PhotoAlbumViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!


    // MARK: - Properties

    // array to store photos that will display in collectionView
    var photoArray = [Photo]() // NSManagedObject

//    var selectedPin: Pin? {
//        didSet{
//            // all code in this body will be called once selectedCategory gets a value (!= nil)
//            // when we call loadItems() we are confident that we already have a value for selected category
//            // all we want to do is load up the items that fit the current selected category
//            // We no longer need to call loadItems() in viewDidLoad b/c we now call it here when we set the value for selectedCategory.
//            loadPhotos()
//        }
//    }

    // Data Model
    // (UIApplication.shared.delegate as! AppDelegate) gives us access to the AppDelegate object. We can not tap into its property 'persistentContainer and we are going to grab the 'viewContext' of the persistentContainer.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let reuseIdentifier = "FlickrCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50, right: 20.0)


    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            collectionView.reloadData()
        }
    }




    // flickr - a reference to the object that will do the searching for you

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

        // We want to get a path of where our current data is being stored.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        // Configure the DataSource and Delegate to the CollectionView Outliet
        collectionView.delegate = self
        collectionView.dataSource = self

//        mapView.delegate = self

//        // Get the stack
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        let stack = delegate.stack

        // call the helper method to zoom into initialLocation at load
        centerMapOnLocation(location: initialLocation)

//        // Create a fetchrequest
//        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
//        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
//                              NSSortDescriptor(key: "creationDate", ascending: false)]
//
//        // Create the FetchedResultsController
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
//
//        // Fetch photos
//        try! fetchedResultsController?.performFetch()

        loadPhotos()

    }

    func loadPhotos() {

        // specify the data type and the <entity> that you're trying to request.
        // Tap into our Item class/entity and create a new fetchRequest()
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()

        // our app has to speak to the context before we can speak to our persistantContainer
        // we want to fetch our current request, which is basically a blank request that returns everything in our persistantContainer, it can throw an error so put it inside a do-try-catch statement.
        do {
            // fetch(T) returns NSFetchRequestResult, which is an array of objects / of 'Items' that is stored in our persistantContainer
            // save results in the itemArray which is what was used to load up the tableView.
            photoArray = try context.fetch(request)
        } catch {
            print("loadItems(): Error fetching data from context \(error)")
        }
    }










}


// MARK: - CoreDataTableViewController (Fetches)

extension PhotoAlbumViewController {

    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
}


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
    // ************ This is a unique method when it comes to Core Data
    // This is a placeholder method just to return a blank cell - you'll be populating it later. Note that collection views require you to have registered a cell with a reuse identifier, or a runtime error will occur.
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // fatalError("This method MUST be implemented by a subclass of PhotoAlbumViewController")

        // This method must be implemented by our subclass. There's no way CoreDataTableViewController is able to know what type of cell we want to use.

        // Core Data steps:
        // a. Find the right Pin that we need
            // a.a NSFetchResults has a method called Object For indexPath
//        let pin = fetchedResultsController!.object(at: indexPath) as! Pin

        // b. Create the cell
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell

        // Sync Pin -> cell (display the information from the Pin in the cell)
        cell.backgroundColor = UIColor.white


        // 1
        // The cell coming back is FlickPhotoCellectionViewCell





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
// MARK: - CoreDataTableViewController: NSFetchedResultsControllerDelegate

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {

//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//
//        let set = IndexSet(integer: sectionIndex)
//
//        switch (type) {
//        case .insert:
//            tableView.insertSections(set, with: .fade)
//        case .delete:
//            tableView.deleteSections(set, with: .fade)
//        default:
//            // irrelevant in our case
//            break
//        }
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//
//        switch(type) {
//        case .insert:
//            tableView.insertRows(at: [newIndexPath!], with: .fade)
//        case .delete:
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//        case .update:
//            tableView.reloadRows(at: [indexPath!], with: .fade)
//        case .move:
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//            tableView.insertRows(at: [newIndexPath!], with: .fade)
//        }
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
}




