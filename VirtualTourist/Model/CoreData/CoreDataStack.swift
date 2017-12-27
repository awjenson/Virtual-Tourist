//
//  CoreDataStack.swift
//
//  Created by Fernando Rodríguez Romero on 21/02/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

// This is the boilerplate class from the Apple developers' site on Core Data.

// *** To create our Managed Objects, in the .xcdatamodeld file, click Editor > Create NSManagedObject Subclass. Select the model file we'd like to create entity classes from and then the entities or objects we would like to be managed. Select both Photo and Pin because we want to manage both of them. Click Next and then Create. Two files will be created.
// You have a class file and an extension. The extension file contains code that matches up with your object model.  You never want to add any comments/code in these extension file b/c xCode will overwrite them and recreate the class if you modify the model.
// The other two file are the Class files (Photo and Pin).
// conveince init(): What we need to do now is add an init method so that this class can create useable instances of itself. We'll add i a convenience init which takes text, a string with the words new Note init and an NSMnagedObject context called, Context. Then, what we need to do is create an NSEntityDescription. Any entity descriptino is an object that has access to all the information we provided in the entity part of the model. And it's needed in order to instantiate any managed object class. For the entity description we call the entity for name. Which takes in the name of the entity so in this case, Note, and the context in which we want the Note to live, in mangaged object context: context. Then we can call the designated initializer, which is the initializer for NSManagedObject, the superclass, which takes in the entity description and the context in order to create a new instance. The parameter name says, insertIntoManagedObjectContext, which is where the instance will live. Every single core data object needs to know its context. Next, we initialize some properites, text will equal text which we can remember is the new note (unsure how this transfers to Tourist app). And creation data will get initialized to NSData object. Put in a fatal error in case no entity exists. Now repeat this for the other class (e.g. Pin class). 

import CoreData

// MARK: - CoreDataStack

struct CoreDataStack {
//
//    // MARK: Properties
//
//    private let model: NSManagedObjectModel
//    internal let coordinator: NSPersistentStoreCoordinator
//    private let modelURL: URL
//    internal let dbURL: URL
//    internal let persistingContext: NSManagedObjectContext
//    internal let backgroundContext: NSManagedObjectContext
//    let context: NSManagedObjectContext
//
//    // MARK: Initializers
//
//    init?(modelName: String) {
//
//        // Assumes the model is in the main bundle
//        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
//            print("Unable to find \(modelName)in the main bundle")
//            return nil
//        }
//        self.modelURL = modelURL
//
//        // Try to create the model from the URL
//        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
//            print("unable to create a model from \(modelURL)")
//            return nil
//        }
//        self.model = model
//
//        // Create the store coordinator
//        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
//
//        // Create a persistingContext (private queue) and a child one (main queue)
//        // create a context and add connect it to the coordinator
//        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        persistingContext.persistentStoreCoordinator = coordinator
//
//        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        context.parent = persistingContext
//
//        // Create a background context child of main context (Concurrent Core Data)
//        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        backgroundContext.parent = context
//
//        // Add a SQLite store located in the documents folder
//        let fm = FileManager.default
//
//        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            print("Unable to reach the documents folder")
//            return nil
//        }
//
//        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
//
//        // Options for migration
//        let options = [NSInferMappingModelAutomaticallyOption: true,NSMigratePersistentStoresAutomaticallyOption: true]
//
//        do {
//            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : AnyObject]?)
//        } catch {
//            print("unable to add store at \(dbURL)")
//        }
//    }
//
//    // MARK: Utils
//
//    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
//        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
//    }
//}
//
//// MARK: - CoreDataStack (Removing Data)
//
//internal extension CoreDataStack  {
//
//    func dropAllData() throws {
//        // delete all the objects in the db. This won't delete the files, it will
//        // just leave empty tables.
//        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType , options: nil)
//        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
//    }
//}
//
//// MARK: - CoreDataStack (Batch Processing in the Background Thread)
//
//extension CoreDataStack {
//
//    // see backgroundContext above.
//    // Below: Modify our CoreDataStack class with an extension so it has a private backgroundContext, child of the main context. On top of that let’s add a method, performBackgroundBatchOperation( that allows us to submit a “batch” closure that will run in the background, and once it’s done, saves from the background context to the main one. This way, as soon as the background batch operation is done, all the new objects are available in the main context.
//
//    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
//
//    func performBackgroundBatchOperation(_ batch: @escaping Batch) {
//
//        backgroundContext.perform() {
//
//            batch(self.backgroundContext)
//
//            // Save it to the parent context, so normal saving
//            // can work
//            do {
//                try self.backgroundContext.save()
//            } catch {
//                fatalError("Error while saving backgroundContext: \(error)")
//            }
//        }
//    }
//}
//
//// MARK: - CoreDataStack (Save Data)
//
//extension CoreDataStack {
//
//    func save() {
//        // We call this synchronously, but it's a very fast
//        // operation (it doesn't hit the disk). We need to know
//        // when it ends so we can call the next save (on the persisting
//        // context). This last one might take some time and is done
//        // in a background queue
//        context.performAndWait() {
//
//            // On context.save():
//            // 1. All properties and relationships are validated.
//            // 2. All new and modified objects are saved to disk.
//            // 3. All deleted objects are removed from the database.
//            // These steps could take a long time to complete, that is why we need to cafefully choose when to call this function. If we call it after every change that the user makes then the app will become sluggish and possible timeout. But, if we call it too seldomly, we risk the user potentially losing data.
//            // So when is the right time to save? Look at the AppDelegate.
//            if self.context.hasChanges {
//                do {
//                    try self.context.save()
//                } catch {
//                    fatalError("Error while saving main context: \(error)")
//                }
//
//                // Saving in a Background Queue:
//                // A persisting context in a private queue. This one saves to the coordinator, and since it’s on a private queue, it will save in the background. This is the only responsibility it has and it will do nothing else but saving.
//                // now we save in the background
//                self.persistingContext.perform() {
//                    do {
//                        try self.persistingContext.save()
//                    } catch {
//                        fatalError("Error while saving persisting context: \(error)")
//                    }
//                }
//            }
//        }
//    }
//
////    func autoSave(_ delayInSeconds : Int) {
////
////        if delayInSeconds > 0 {
////            do {
////                try self.context.save()
////                print("Autosaving")
////            } catch {
////                print("Error while autosaving")
////            }
////
////            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
////            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
////
////            DispatchQueue.main.asyncAfter(deadline: time) {
////                self.autoSave(delayInSeconds)
////            }
////        }
////    }
}
