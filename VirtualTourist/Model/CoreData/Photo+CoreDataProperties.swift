//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 1/10/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var pin: Pin?

}
