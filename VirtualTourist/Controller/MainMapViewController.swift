//
//  MainMapViewController.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 12/12/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

// Sources:
// Drop a pin in a map view: https://codepad.co/snippet/JgYdAoXd
// Core Data: https://www.udemy.com/ios-11-app-development-bootcamp/learn/v4/t/lecture/8790828?start=0

import UIKit
import MapKit
import CoreData

// MainMapViewController will be the delegate for the map view
class MainMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    // MARK: - Outlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    var currentPin: Pin?
    var coordinatesForPin = CLLocationCoordinate2D()

    // flickr is a reference to the object that will do the searching for you
    fileprivate let flickr = Flickr()



    var pins = [Pin]()
    var selectedPin: Pin? = nil


    // Udacity comments, "When a new Pin is created, the Context sends a notification to the fetchedResultsController. fetchedResultsController uses a delegate (NSFetchedResultsControllerDelegate) to communiate to MainMapViewController.
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self
        }
    }

    // MARK: Initializers

    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }





    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()

        // Path to Data Model
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))




        // create NSFetchedResultsController
        

        // Assign delegate
        mapView.delegate = self

        // fetch all existing pins (is any) from the view context
        fetchAllSavedAnnotations()

        // Add gesture recognizer to Enable User to Drop a Pin
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: #selector(MainMapViewController.recognizeLongPress(sender:)))
        mapView.addGestureRecognizer(myLongPress)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true

    }

    // MARK: - Core Data Methods

    // Fetch all saved annotations in order to display on mapView
    func fetchAllSavedAnnotations() {

        pins = pinFetchRequest()

        for pin in pins {
            let annotation = MKPointAnnotation()
            // pin.coordinate created in initialization inside Pin+CoreDataClass file
            annotation.coordinate = pin.coordinate
            mapView.addAnnotation(annotation)
        }
    }





    // MARK: - Gesture Recognizer Methods

    // Gesture Recognizer for Dropping a Pin on Map, then Save Pin in Core Data and Run Flickr API Network Request
    @objc func recognizeLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began {
            return
        }

        // **** Drop a Pin = Create a new Pin object ****
        let location = sender.location(in: mapView)
        let newCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)

        // Create new annotation (pin)
        let annotation: MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = newCoordinate
        print("Pin dropped - latitude: \(annotation.coordinate.latitude), longitude: \(annotation.coordinate.longitude).")
        // Add pin to mapView
        mapView.addAnnotation(annotation)

        
        // **** Core Data (Save Pin) ****
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: stack.context) {

            // Create New Pin Object
            let newPin = Pin(entity: ent, insertInto: stack?.context)
            newPin.latitude = annotation.coordinate.latitude
            newPin.longitude = annotation.coordinate.longitude

            // Append newPin to Pin Entity
            pins.append(newPin)


            // **** Cordinates Saved, Begin Flickr API Request
            flickr.searchFlickrForCoordinates(pin: newPin) { (results, errorString) in

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
                        //                    self.enableUI()
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
                            if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.stack.context) {
                                photoTemp = Photo(entity: entity, insertInto: self.stack.context)
                                photoTemp?.imageURL = photo[Constants.FlickrParameterValues.MediumURL] as? String
                                photoTemp?.pin = newPin
                            }
                        }
                    }
                    print("reload complete")
                    // Rubric: When pins are dropped on the map, the pins are persisted as Pin instances in Core Data and the context is saved.
                    self.stack.save()
                }
                return
            } // End of Flickr Closure
        } // End of NSEntityDescription.entity()
    } // End of recognizeLongPress()

    // MARK: - Map View Methods

    // Drop a Pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let myPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PinAnnotationIdentifier")
        myPinView.animatesDrop = true
        myPinView.annotation = annotation

        return myPinView
    }

    // Enable the User to Select a Pin and Segue to Collection View
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        let annotation = view.annotation
        selectedPin = nil

        for pin in pins {
            if annotation!.coordinate.latitude == pin.coordinate.latitude && annotation!.coordinate.longitude == pin.coordinate.longitude {

                selectedPin = pin

                // perform segue to next VC
                performSegue(withIdentifier: "PinTappedSegue", sender: self)

                // Deselect the pin that was tapped most recently
                mapView.deselectAnnotation(annotation, animated: true)
            }
        }
    }

    // MARK: - Segue Methods (called in mapView didSelect)

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier {
        case "PinTappedSegue"?:

            let destinationVC = segue.destination as! PhotoAlbumViewController
            destinationVC.pinSelected = selectedPin
            print("Pin Tapped -> Segue to Next VC")

        default:
            print("Could not find segue")
        }
    }





    // MARK: - Core Data
    func pinFetchRequest() -> [Pin] {

        // 2. Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true), NSSortDescriptor(key: "longitude", ascending: true)]

        // 3. Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)

        // fetch desired fetchRequest of the saved annotations
        do {
            return try stack.context.fetch(fr) as! [Pin]
        } catch {
            print("pinFetchRequest(): Error fetching the saved annotations")
            return [Pin]()
        }

    }



    func getPin(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> [Pin]? {
        let fetchRequest = getFetchRequest(entityName: "Pin", format: "latitude = %@ && longitude = %@", argArray: [latitude, longitude])

        let pins: [Pin]? = fetchPin(fetchRequest: fetchRequest)
        return pins
    }

    func fetchPin(fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [Pin]? {
        var pins: [Pin]?

        do {
            pins = try self.stack?.context.fetch(fetchRequest) as? [Pin]

        } catch {
            print("fetchPin(): Error, pin not found")
        }
        return pins
    }

    func getFetchRequest(entityName: String, format: String, argArray: [Any]?) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)

        let predicate = NSPredicate(format: format, argumentArray: argArray)
        fetchRequest.predicate = predicate

        return fetchRequest
    }












}











