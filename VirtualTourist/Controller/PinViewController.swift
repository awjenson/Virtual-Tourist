//
//  PinsViewController.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 12/22/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// MARK: - PinViewController: CoreDataPhotoAlbumViewController

class PinViewController: PhotoAlbumViewController {

//    // MARK: Life Cycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Create an NSFetchedResultsController in viewDidLoad. We will need 3 things: An initialized stack, a fetched request, and finally, the NSFetchResultsController
//
//        // 1. Get the stack
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        let stack = delegate.stack
//
//        // 2. Create a fetchrequest
//        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
//        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
//                              NSSortDescriptor(key: "creationDate", ascending: false)]
//
//        // 3. Create the FetchedResultsController
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
//    }
//
//    // MARK: Actions
//
//    @IBAction func addNewPin(_ sender: AnyObject) {
//        // Create a new notebook... and Core Data takes care of the rest!
//        let pin = Pin(name: "New Pin", context: fetchedResultsController!.managedObjectContext)
//        print("Just created a pin: \(pin)")
//    }
//
//    // MARK: TableView Data Source
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        // This method must be implemented by our subclass. There's no way
//        // CoreDataPhotoAlbumViewController can know what type of cell we want to
//        // use.
//
//        // Find the right notebook for this indexpath
//        let pin = fetchedResultsController!.object(at: indexPath) as! Pin
//
//        // Create the cell
//        let cell = collectionView.dequeueReusableCell(withIdentifier: "FlickrCell", for: indexPath)
//
//        // Sync notebook -> cell
//        cell.imageView = pin.image
//        
//
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if let context = fetchedResultsController?.managedObjectContext, let noteBook = fetchedResultsController?.object(at: indexPath) as? Notebook, editingStyle == .delete {
//            context.delete(noteBook)
//        }
//    }
//
//    // MARK: Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//
//        if segue.identifier! == "displayPhotos" {
//
//            if let notesVC = segue.destination as? NotesViewController {
//
//                // Create Fetch Request
//                let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
//
//                fr.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false),NSSortDescriptor(key: "text", ascending: true)]
//
//                // So far we have a search that will match ALL notes. However, we're
//                // only interested in those within the current notebook:
//                // NSPredicate to the rescue!
//                // Predicates represent logical conditions, which you can use to filter collections of objects.
//                let indexPath = tableView.indexPathForSelectedRow!
//                let notebook = fetchedResultsController?.object(at: indexPath) as? Notebook
//
//                let pred = NSPredicate(format: "notebook = %@", argumentArray: [notebook!])
//
//                fr.predicate = pred
//
//                // Create FetchedResultsController
//                let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext:fetchedResultsController!.managedObjectContext, sectionNameKeyPath: "humanReadableAge", cacheName: nil)
//
//                // Inject it into the notesVC
//                notesVC.fetchedResultsController = fc
//
//                // Inject the notebook too!
//                notesVC.notebook = notebook
//            }
//        }
//    }

    
}

