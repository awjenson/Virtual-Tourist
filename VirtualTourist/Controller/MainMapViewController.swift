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
class MainMapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Outlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties

    var pinArray = [Pin]()
    var photoArray = [Photo]() // ???


    // data model
    // CRUD: Create, Read, Updatet, Delete
    // 'context' goes into the AppDelegate and grabs the persistentContainer, and then we grab a reference of the viewContext for that persistantContainer. 
    // (UIApplication.shared.delegate as! AppDelegate) gives us access to the AppDelegate object. We can not tap into its property 'persistentContainer and we are going to grab the 'viewContext' of the persistentContainer.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()

        // Path to Data Model
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        // Assign delegate
        mapView.delegate = self

        // fetch all existing pins (is any) from the view context
        loadPins()

        // Enable the user to drop a pin on the mapView
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: #selector(MainMapViewController.recognizeLongPress(sender:)))
        mapView.addGestureRecognizer(myLongPress)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true

    }

    // MARK: - Data Manipulation Methods

    // Load Data
    // Read data here
    // Method with Default Value listed inside loadItems(): = Item.fetchRequest() in case not parameter passed in (see viewDidLoad).
    func loadPins(with request: NSFetchRequest<Pin> = Pin.fetchRequest()) {

        let request: NSFetchRequest<Pin> = Pin.fetchRequest()

        do {
            pinArray = try context.fetch(request)
        } catch {
            print("loadPins(): Error fetching data from context \(error)")
        }
//        tableView.reloadData()
    }

    // Save Data
    func saveToDataModel() {
        do {
            // try to commit whatever is in current context
            try context.save()
        } catch {
            print("saveCategories(): Error saving context \(error)")
        }
        //        // After save, update tableView
        //        tableView.reloadData()
    }


    // MARK: - Gesture Recognizer Methods

    // Gesture Recognizer for Dropping a Pin on Map
    @objc func recognizeLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began {
            return
        }

        // **** Drop a Pin ****
        let location = sender.location(in: mapView)
        let newCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        let pin: MKPointAnnotation = MKPointAnnotation()
        pin.coordinate = newCoordinate
        print("Pin dropped - latitude: \(pin.coordinate.latitude), longitude: \(pin.coordinate.longitude).")
        mapView.addAnnotation(pin)


        // **** Core Data (Pin) ****
        // When pins are dropped on the map, the pins are persisted as Pin instances in Core Data and the context is saved.
        // 1. Create a new NSManagedObject, newPin
        let newPin = Pin(context: self.context)

        // 2. Setup newPin with the new pin's coordinates

        // add coordinates to newPin
        newPin.latitude = pin.coordinate.latitude
        newPin.longitude = pin.coordinate.longitude

        // append newPin to pinArray
        self.pinArray.append(newPin)
        print("pinArray: \(self.pinArray)")

        // save to data model
        self.saveToDataModel()
        //**** Core Data ****

        
        // **** Flickr Network Request ****

        // Coordinates contain a value, save them to Constant file properties to use in Flickr API photos search
        Constants.SelectedPin.latitude = pin.coordinate.latitude
        Constants.SelectedPin.longitude = pin.coordinate.longitude

        Flickr.sharedInstance().searchFlickrForCoordinates { (success, errorString) in

            print("Running network request on the main thread?: \(Thread.isMainThread)")

            /* GUARD: Was there an error? */
            guard (success == true) else {
                // display the errorString using createAlert
                // The app gracefully handles a failure to download student locations.
                print("Unsuccessful in obtaining photos of selected location from Flickr: \(errorString)")

                performUIUpdatesOnMain {
                    self.createAlert(title: "Error", message: "Failure to download photos of location.")
                    //                    self.enableUI()
                }
                return
            }


            print("Successfully obtained Photos from Flickr")
            // After all are successful, perfore segue

        } // End of Closure



        
    }

    // MARK: - Map View Methods

    // Drop a Pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let myPinIdentifier = "PinAnnotationIdentifier"
        let myPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: myPinIdentifier)
        myPinView.animatesDrop = true
        myPinView.annotation = annotation

        return myPinView
    }

    // Enable the User to Select a Pin
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        // You want to trigger a search when the user selects a pin.
        // perform segue to next VC
        performSegue(withIdentifier: "PinTappedSegue", sender: self)

    }

    // MARK: - Segue Methods

    func segueToPhotoAlbumViewController() {

        performUIUpdatesOnMain {
            self.performSegue(withIdentifier: "PinTappedSegue", sender: self)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidesWhenStopped = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PinTappedSegue" {
            let destinationVC = segue.destination as! PhotoAlbumViewController

            // send cordinates to Flickr API

            // download the imageURLs in a for loop

            // insert them into NSManagedObject

            // assign current VC (self) as the delegate

            // Pass images to next view controller

            // Present next view controller
            //present(destinationVC, animated: true, completion: nil)

        }
    }









//    func updateMapView() {
//
//        performUIUpdatesOnMain {self.displayUpdatedAnnotations()}
//    }
//
//    func displayUpdatedAnnotations() {
//
//        // Populate the mapView with 100 pins:
//        // use sharedinstance() because it's a singleton
//        // Forum Mentor: "arrayOfStudentLocations is given a value in a background thread. Make sure you dispatch that on the main thread."
//
//        self.mapView.removeAnnotations(mapView.annotations)
//
//        // We will create an MKPointAnnotation for each dictionary in "locations". The
//        // point annotations will be stored in this array, and then provided to the map view.
//        var newAnnotations = [MKPointAnnotation]()
//
//        // The "locations" array is loaded with the sample data below. We are using the dictionaries
//        // to create map annotations. This would be more stylish if the dictionaries were being
//        // used to create custom structs. Perhaps StudentLocation structs.
//
//        // This is an array of studentLocations (struct StudentLocation)
//        for student in studentLocations {
//
//            // Notice that the float values are being used to create CLLocationDegree values.
//            // This is a version of the Double type.
//            // CLLocationDegrees is of type Double
//            let lat = CLLocationDegrees(student.latitude)
//            let long = CLLocationDegrees(student.longitude)
//
//            // The lat and long are used to create a CLLocationCoordinates2D instance.
//            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//
//            // set constants to the StudentLocation data to be displayed in each pin
//            let first = student.firstName
//            let last = student.lastName
//            let mediaURL = student.mediaURL
//
//            // Here we create the annotation and set its coordiate, title, and subtitle properties
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
//            annotation.title = "\(first) \(last)"
//            annotation.subtitle = mediaURL
//
//            // Finally we place the annotation in an array of annotations.
//            newAnnotations.append(annotation)
//        }
//        // When the array is complete, we add the annotations to the map.
//        self.mapView.addAnnotations(newAnnotations)
//    }




}

