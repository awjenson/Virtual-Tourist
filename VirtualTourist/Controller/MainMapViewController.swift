//
//  MainMapViewController.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 12/12/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

// Sources:
// Drop a pin in a map view: https://codepad.co/snippet/JgYdAoXd

import UIKit
import MapKit

// MainMapViewController will be the delegate for the map view
class MainMapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Properties

    fileprivate let flickr = Flickr() // What is this???

    


    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()


        // Assign delegate
        mapView.delegate = self

        // Enable the user to drop a pin on the mapView
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: #selector(MainMapViewController.recognizeLongPress(sender:)))
        mapView.addGestureRecognizer(myLongPress)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)


    }


    // Gesture Recognizer for Dropping a Pin on Map
    @objc func recognizeLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began {
            return
        }
        let location = sender.location(in: mapView)
        let myCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        let myPin: MKPointAnnotation = MKPointAnnotation()
        myPin.coordinate = myCoordinate
        print("Pin dropped - latitude: \(myPin.coordinate.latitude), longitude: \(myPin.coordinate.longitude).")
        mapView.addAnnotation(myPin)
    }


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

        guard let selectedLatitude = view.annotation?.coordinate.latitude, let selectedLongitude = view.annotation?.coordinate.longitude else {
            print("Error with selected pin latitudue and longitude")
            return
        }

        // Coordinates contain a value, save them to Constant file properties to use in Flickr photos search
        Constants.SelectedPin.latitude = selectedLatitude
        Constants.SelectedPin.longitude = selectedLongitude

        print("")
        print("$$$ Passing a pin to download images for cordinates:")
        print("Saved Lat: \(Constants.SelectedPin.latitude)")
        print("Saved Long: \(Constants.SelectedPin.longitude)")
        print("")

        Flickr.sharedInstance().searchFlickrForCoordinates { (success, errorString) in

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

            print("Successfully obtained Photos from Flickr, segue to next VC")
            // After all are successful, perfore segue
            self.segueToPhotoAlbumViewController()

        } // End of Closure
    }

    // MARK: - Methods

    func segueToPhotoAlbumViewController() {

        performUIUpdatesOnMain {
            self.performSegue(withIdentifier: "PinTappedSegue", sender: self)
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

