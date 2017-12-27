//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 12/22/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import UIKit

// MARK: - PhotosViewController: CoreDataTableViewController

class PhotosViewController: PhotoAlbumViewController {

//    // MARK: Properties
//
//
//
//    // MARK: Actions
//
//
//
//    // MARK: TableView Data Source
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        // Get the note
//        let note = fetchedResultsController?.object(at: indexPath) as! Note
//
//        // Get the cell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
//
//        // Sync note -> cell
//        cell.textLabel?.text = note.text
//
//        // Return the cell
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//        if let context = fetchedResultsController?.managedObjectContext, let note = fetchedResultsController?.object(at: indexPath) as? Note, editingStyle == .delete {
//            context.delete(note)
//        }
//    }


}
