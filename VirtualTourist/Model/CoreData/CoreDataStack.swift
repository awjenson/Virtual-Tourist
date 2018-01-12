//
//  CoreDataStack.swift
//
//  Created by Fernando Rodríguez Romero on 21/02/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//
// The Core Data stack is set up and managed by the CoreDataStack class. It provides access to the main managed object context, neatly hiding the private managed object context, the managed object model, and the persistent store coordinator from the rest of the application.

// every Core Data stack is composed of three building blocks: a persistent store coordinator (private), a managed object model (private), and a managed object context (public)

// MARK: - From Udacity's Cool Notes App

import UIKit
import CoreData

// MARK: - GLOBAL VARIABLES

let delegate = UIApplication.shared.delegate as! AppDelegate
let context = (UIApplication.shared.delegate as! AppDelegate).stack.context

// MARK: - CoreDataStack

struct CoreDataStack {

    // MARK: Properties

    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let dbURL: URL
    internal let persistingContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext
    let context: NSManagedObjectContext

    // MARK: Initializers

    init?(modelName: String) {

        // Assumes the model is in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName)in the main bundle")
            return nil
        }
        self.modelURL = modelURL

        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model

        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

        // Create a persistingContext (private queue) and a child one (main queue)
        // create a context and add connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator

        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext

        // Create a background context child of main context (Concurrent Core Data)
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context

        // Add a SQLite store located in the documents folder
        let fm = FileManager.default

        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach the documents folder")
            return nil
        }

        self.dbURL = docUrl.appendingPathComponent("model.sqlite")

        // Options for migration
        let options = [NSInferMappingModelAutomaticallyOption: true,NSMigratePersistentStoresAutomaticallyOption: true]

        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("unable to add store at \(dbURL)")
        }
    }

    // MARK: Utils

    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
}


// MARK: - CoreDataStack (Removing Data)

internal extension CoreDataStack  {

    func dropAllData() throws {
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try coordinator.destroyPersistentStore(at: dbURL, ofType:NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}

// MARK: - CoreDataStack (Save Data)

extension CoreDataStack {

    func save() {
        // We call this synchronously, but it's a very fast
        // operation (it doesn't hit the disk). We need to know
        // when it ends so we can call the next save (on the persisting
        // context). This last one might take some time and is done
        // in a background queue
        context.performAndWait() {

            // On context.save():
            // 1. All properties and relationships are validated.
            // 2. All new and modified objects are saved to disk.
            // 3. All deleted objects are removed from the database.
            // These steps could take a long time to complete, that is why we need to cafefully choose when to call this function. If we call it after every change that the user makes then the app will become sluggish and possible timeout. But, if we call it too seldomly, we risk the user potentially losing data.
            // So when is the right time to save? Look at the AppDelegate.
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }

                // Saving in a Background Queue:
                // A persisting context in a private queue. This one saves to the coordinator, and since it’s on a private queue, it will save in the background. This is the only responsibility it has and it will do nothing else but saving.
                // now we save in the background
                self.persistingContext.perform() {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }

}

