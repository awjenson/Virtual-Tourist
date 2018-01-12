//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 1/10/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit // used for fetching existing annotations for mapView


public class Pin: NSManagedObject, MKAnnotation {

    public var coordinate: CLLocationCoordinate2D {
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        } get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }


    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            print("Pin+CoreDataClass: New Pin Created")
        } else {
            fatalError("Unable to find Entity name (Pin)!")
        }
    }
}

