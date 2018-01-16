//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 12/12/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import UIKit
import CoreData // MARK: - From Udacity's Cool Notes App

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - From Udacity's Cool Notes App
    let stack = CoreDataStack(modelName: "DataModel")!

    // MARK: - Udacity's Code from Lesson 1: Simple Persistance
    func checkIfFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            print("App has launched before")
        } else {
            print("This is the first launch ever!")
        }
    }


    // MARK: - App Delegate Functions

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

        // Placement of Save code is based instructions provided in CoolNotes' lesson 10-SaveOnAppTransition.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        // Placement of Save code is based instructions provided in CoolNotes' lesson 10-SaveOnAppTransition.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
    }







    // MARK: - Core Data stack

    // When we create a variable and declare it as lazy, then it only gets loaded up with a value at the time point when it is needed. i.e. when we try to use the variable. This saves on memory.
    // PersistentContainer is where we are going to store all of our data in a SQLite database.
    // For this project 'container' will be a SQLite Database
    lazy var persistentContainer: NSPersistentContainer = {
        // the perstanceContainer, called 'container', is the data base that we will be saving to and it is a SQLite database.
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */

        // NSPersistentContainer name MUST match the data model name.
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            // Log if there were any errors
            // If there were no errors then we are going to return the container that we loaded up and we're going to set it as the value this lazy variable called 'persistentContainer' and we will be able to access it inside other classes in order to persist and save our data into our SQLite database.
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    // the 'context' is an area where you can change and update your data so you can undo and redo until your happy with your data. And then you can save the data that is in your context (temp area) to the 'container' which is for permenent storage.
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

