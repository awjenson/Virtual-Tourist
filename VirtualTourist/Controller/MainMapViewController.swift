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
    @IBOutlet weak var editButton: UIBarButtonItem!

    @IBOutlet weak var editModeLabelButton: UIButton!

    // MARK: - Properties
    var currentPin: Pin?
    var coordinatesForPin = CLLocationCoordinate2D()
    var pins = [Pin]()
    var selectedPin: Pin? = nil

    // flickr is a reference to the object that will do the searching for you
    fileprivate let flickr = Flickr()
    // Edit Mode used to delete pins
    var isEditModeOn = false

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

        editButton.title = "Edit"
        editModeLabelButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        // Path to Data Model
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        // Assign delegate
        mapView.delegate = self

        // fetch all existing pins (is any) from the view context
        fetchAllSavedAnnotations()

        // Add gesture recognizer to Enable User to Drop a Pin
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: #selector(MainMapViewController.recognizeLongPress(_:)))
        mapView.addGestureRecognizer(myLongPress)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
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


    // MARK: - Core Data
    func pinFetchRequest() -> [Pin] {

        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true), NSSortDescriptor(key: "longitude", ascending: true)]

        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        // Fetch the saved annotations
        do {
            return try context.fetch(fr) as! [Pin]
        } catch {
            print("pinFetchRequest(): Error fetching the saved annotations")
            return [Pin]()
        }
    }



    // MARK: - Gesture Recognizer Methods

    // Add a New Annotation
    // Gesture Recognizer for Dropping a Pin on Map, then Save Pin in Core Data and Run Flickr API Network Request
    @objc func recognizeLongPress(_ sender: UILongPressGestureRecognizer) {

        if sender.state != UIGestureRecognizerState.began {
            return
        }

        // **** Drop a Pin = Create a new Pin object ****
        let location = sender.location(in: mapView)
        let newCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)

        // Create new annotation (pin)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinate
        print("Pin dropped - latitude: \(annotation.coordinate.latitude), longitude: \(annotation.coordinate.longitude).")

        // Add pin to mapView
        mapView.addAnnotation(annotation)

        
        // **** Core Data (Save Pin) ****
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {

            // Create New Pin Object
            let newPin = Pin(entity: ent, insertInto: context)
            newPin.latitude = annotation.coordinate.latitude
            newPin.longitude = annotation.coordinate.longitude

            // Append newPin to Pin Entity
            pins.append(newPin)


            // **** Cordinates Saved, Begin Flickr API Request
            flickr.searchFlickrForCoordinates(pin: newPin) { (arrayOfImageUrlStrings, errorString) in

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
                        //                    self.enableUI()
                    }
                    return
                }

                print("Successfully obtained Photos from Flickr")

                // Take 'arrayOfImageUrlStrings' and implement for-loop to save to context on the main thread.
                performUIUpdatesOnMain {

                    var photoCoreData: Photo?

                    print("recognizeLongPress(): Get photos for selected pin.")

                    // **** Core Data: Add web URLs and Pin(s) only at this point...
                    if photoCoreData == nil {
                        for imageUrlString in arrayOfImageUrlStrings! {
                            if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
                                photoCoreData = Photo(entity: entity, insertInto: context)

                                // Save image URL String to the "Photo" Entity
                                photoCoreData?.imageURL = imageUrlString[Constants.FlickrParameterValues.MediumURL] as? String
                                photoCoreData?.pin = newPin

                            }
                        }
                    }

                    // Save from URL String to NSData
                    print("photoCoreData?.pin: \(String(describing: photoCoreData?.pin!))")
                    print("Flickr Photo URL String Download Complete, save context")
                    // Rubric: When pins are dropped on the map, the pins are persisted as Pin instances in Core Data and the context is saved.
                    delegate.stack.save()

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
        let lat = annotation?.coordinate.latitude
        let long = annotation?.coordinate.longitude

        selectedPin = nil
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let fetchResults = try context.fetch(fetchRequest)

            for pin in fetchResults as [Pin] {

                if pin.latitude == lat!, pin.longitude == long! {
                    selectedPin = pin
                    print("Found pin info.")

                    if isEditModeOn == true {
                        // In edit mode, delete selected pin
                        performUIUpdatesOnMain {
                            context.delete(self.selectedPin!)
                            delegate.stack.save()
                            self.mapView.removeAnnotation(annotation!)
                            print("Deleted selected pin")
                        }

                    } else {
                        // Not in edit mode, so segue
                        // perform segue to next VC
                        performUIUpdatesOnMain {
                            self.performSegue(withIdentifier: "PinTappedSegue", sender: self)

                            // Deselect the pin that was tapped most recently
                            mapView.deselectAnnotation(annotation, animated: true)
                        }
                    }   // end of 'else'
                }   // end of 'if pin.latitude == lat!, pin.longitude == long!'
            }   // end of 'for pin in fetchResults'
        } catch {
            print("mapView didSelect: Error \(error)")
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

    // MARK: - IBActions

    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {

        // isEditMode initially set to 'false'
        // set to opposite when tapped
        isEditModeOn = !isEditModeOn

        if isEditModeOn {
            editButton.title = "Done"
            editModeLabelButton.isHidden = false
        } else {
            editButton.title = "Edit"
            editModeLabelButton.isHidden = true
        }
    }

















}











