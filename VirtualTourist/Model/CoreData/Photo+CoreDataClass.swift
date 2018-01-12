//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 1/10/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//
//

import Foundation
import CoreData


public class Photo: NSManagedObject {

    convenience init(imageURL: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.imageURL = imageURL
            print("Photo+CoreDataClass: New Photo Created")
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
