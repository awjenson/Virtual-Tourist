//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 12/12/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//
// Sources:
// Core Data: https://www.raywenderlich.com/173972/getting-started-with-core-data-tutorial-2
// Core Data: https://www.udemy.com/ios-11-app-development-bootcamp/learn/v4/t/lecture/8790828?start=0

import UIKit
import CoreData

class Flickr {

    // MARK: Shared Instance

    class func sharedInstance() -> Flickr {
        struct Singleton {
            static var sharedInstance = Flickr()
        }
        return Singleton.sharedInstance
    }

    // MARK: - Properties

    var pinArrayCoreData = [Pin]()
    var photoArrayCoreData = [Photo]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


    // MARK: Flickr API (URL Set-up)
    // Step 1 - CREATE URL
    func searchFlickrForCoordinates(completion: @escaping (_ success:Bool, _ error:String)->Void){

        // This is creating the URL to set-up the GET Request for the Flickr API

        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPage
        ]

//        self.displayImageFromFlickrBySearch(methodParameters as [String:AnyObject])

        // STEP 2: SEND URL to FLICKR API
        // Call taskForGETRandomPage and pass in parameters for URL Request to get Random Page
        taskForGETRandomPage(methodParameters as [String : AnyObject], completionHandlerForGETRandomPageParseJSON: {

            // Inside Completion Block.
            // taskForGETRandomPage is complete. If results contains data, then
            // Parse JSON data into Swift objects in order to get Random Page
            (data, error) in

            // Parse data and store in static property so that it is ready for use when we segue to PhotoAlbumViewController
            // Lastly, call completionHandler and pass true back to the MainMapViewController in order to segue to next VC that will display the photos.

            // **********************************************************************

            func sendError(_ error: String) {
                print("Error from taskForGETRandomPage: \(error)")
                completion(false, "Could not download photos from selected pin location.")
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            // Parse JSON data into usable Swift objects (store photos).

            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                sendError("Could not parse the data as JSON: '\(data)'")
                return
            }

            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                sendError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }

            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                sendError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }

            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                sendError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                return
            }

//            /* GUARD: Is the "photo" key in photosDictionary? */
//            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
//                sendError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
//                return
//            }

            // Pick a random page
            // Then call another taskForGETRandomPage with the random page in the URL
            // Then parse the JSON to display the photos from the random page

            // pick a random page!
            let randomPage = Int(arc4random_uniform(UInt32(totalPages))) + 1

            print("Total pages: \(totalPages)")
            print("Random page: \(randomPage)")

            // Call next task to GET Photos
            self.taskForGETPhotosFromRandomPage(methodParameters as [String : AnyObject], withPageNumber: randomPage, completionHandlerForGETPhotosFromRandomPageParseJSON: { (data, error) in

                // Inside Completion.
                // Parse data and store in static property so that it is ready for use when we segue to PhotoAlbumViewController
                // Lastly, call completionHandler and pass true back to the MainMapViewController in order to segue to next VC that will display the photos.

                // **********************************************************************

                func sendError(_ error: String) {
                    print("Error from taskForGETRandomPage: \(error)")
                    completion(false, "Could not download photos from selected pin location.")
                }

                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    sendError("No data was returned by the request!")
                    return
                }

                // Parse JSON data into usable Swift objects (store photos).

                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                } catch {
                    sendError("Could not parse the data as JSON: '\(data)'")
                    return
                }

                /* GUARD: Did Flickr return an error (stat != ok)? */
                guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                    sendError("Flickr API returned an error. See error code and message in \(parsedResult)")
                    return
                }

                /* GUARD: Is the "photos" key in our result? */
                guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    sendError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                    return
                }

                /* GUARD: Is "pages" key in the photosDictionary? */
                guard let page = photosDictionary[Constants.FlickrResponseKeys.Page] as? Int else {
                    sendError("Cannot find key '\(Constants.FlickrResponseKeys.Page)' in \(photosDictionary)")
                    return
                }

                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                    sendError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                    return
                }


                // Create an empty array of FlickrPhoto
                var flickrPhotos = [FlickrPhoto]()

                for photoObject in photoArray {
                    guard let photoID = photoObject["id"] as? String,
                        let farm = photoObject["farm"] as? Int ,
                        let server = photoObject["server"] as? String ,
                        let secret = photoObject["secret"] as? String else {
                            break
                    }
                    let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret)

                    guard let url = flickrPhoto.flickrImageURL(),
                        let imageData = try? Data(contentsOf: url as URL) else {
                            break
                    }

//                    guard let image = UIImage(data: imageData) else {
//                        break
//                    }
//
//                    flickrPhoto.thumbnail = image
//                    print("Photos to be displayed: \(String(describing: flickrPhoto.thumbnail))")
//                    // Append photos to array of FlickrPhoto
//                    flickrPhotos.append(flickrPhoto)

                    if let image = UIImage(data: imageData) {
                        flickrPhoto.thumbnail = image
                        print("Photos to be displayed: \(String(describing: flickrPhoto.thumbnail))")
                        // Append photos to array of FlickrPhoto
                        flickrPhotos.append(flickrPhoto)

                        // Core Data ***
                        let newPhoto = Photo(context: self.context)
                        newPhoto.image = imageData
                        newPhoto.parentPin = self.selectedPin
                        self.photoArrayCoreData.append(newPhoto)
                        print("")
                        print("newPhoto.image: \(newPhoto.image!)")
                        print("")
                    }
                }
                self.savePhotos()

                print("flickrPhotos: \(flickrPhotos.count)")

                // TODO: I don't think we need to store this anymore since we are storing coordinates in Core Data

                // Store search results in order to save data for later use
                var flickrSearches = [FlickrSearchResults]()

                let searchResult = FlickrSearchResults(searchLatitude: Constants.SelectedPin.latitude, searchLongitude: Constants.SelectedPin.longitude, searchResults: flickrPhotos)

                flickrSearches.append(searchResult)
                print("print flickrSearches: \(flickrSearches.count)")

                // Call completionHander
                print("completion is TRUE")
                completion(true, "")

            }) // taskForGETPhotosFromRandomPage
        }) // taskForGETRandomPage
    }



    // MARK: - Flickr API Request

    // First GET Request: Used to Retrieve a Random Page (In Prep for Getting Photos)
    func taskForGETRandomPage(_ methodParameters: [String: AnyObject], completionHandlerForGETRandomPageParseJSON:@escaping (_ data: Data?, _ error: NSError?) -> Void) {

        // This is the GET Request to the Flickr API

        // create session and request
        let session = URLSession.shared
        // flickrURLFromParameters: URL
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))

        print("URL request: \(request)")

        let task = session.dataTask(with: request) { data, response, error in

            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                // This completion handler will get call for any of the errors below
                completionHandlerForGETRandomPageParseJSON(nil, NSError(domain: "taskForGETRandomPage", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            // Sucesss. There is data. Call completion handler to pass data up into closure that parses JSON data and stores the photo data into properties to be used for the Collection View.
            completionHandlerForGETRandomPageParseJSON(data, nil)
        }
        task.resume()
    } // End taskForGETRandomPage



    // Second GET Request: Used to Retrieve Photos from the Random Page
    private func taskForGETPhotosFromRandomPage(_ methodParameters: [String: AnyObject], withPageNumber: Int, completionHandlerForGETPhotosFromRandomPageParseJSON:@escaping (_ data: Data?, _ error: NSError?) -> Void) {

        // add the page to the method's parameters
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?

        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParametersWithPageNumber))

        print("URL request: \(request)")

        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in

            // If error
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                // This completion handler will get call for any of the errors below
                completionHandlerForGETPhotosFromRandomPageParseJSON(nil, NSError(domain: "taskForGETPhotosFromRandomPageParseJSON", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            completionHandlerForGETPhotosFromRandomPageParseJSON(data, nil)
        }
        // start the task!
        task.resume()
    }




















    // MARK: - HELPERS

    // MARK: Help for adding latitude and longitude to URL

    private func bboxString() -> String {
        // ensure bbox is bounded by minimum and maximums
        let latitude = Constants.SelectedPin.latitude
        let longitude = Constants.SelectedPin.longitude

        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }

    // MARK: - Helper for Creating a URL from Parameters

    // Returns a URL
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {

        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()

        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        return components.url!
    }


    // MARK: - Core Data

    var photoArray = [Photo]()

    var selectedPin: Pin? {
        didSet{
            // all code in this body will be called once selectedCategory gets a value (!= nil)
            // when we call loadItems() we are confident that we already have a value for selected category
            // all we want to do is load up the items that fit the current selected category
            // We no longer need to call loadItems() in viewDidLoad b/c we now call it here when we set the value for selectedCategory.
            loadPhotos()
        }
    }

    func savePhotos() {
        // no matter how you decide to update your NSManagedObject, you still need to call context.save()
        // because we're doing all of the CRUD changes inside the context (temp area). And it's only after we are happy with our changes do we call context.save() to COMMIT our changes to our preminent container.
        do {
            // Take the current state of the context and save (COMMIT) changes to our persistantContainer.
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        //        // after saving/committing data, reload the tableView
        //        self.tableView.reloadData()
    }


    // How is our TodoListViewController loading up all of the items in the table view?
    // 1. The items come from the itemArray
    // 2. The itemArry comes from the loadItems()
    // 3. The loadItems() fetches all of the NSManagedObjects that belong in the <Item> Entity.
    // 4. But in order to only load the items that have the parent category matching the selectedCategory, we need to (1) query our database and we need to (2) filter our results.
    // 5. We need to create a predicate that is an NSPredicate and initialize it with the formt that the parent category of all of the items that we want back must have its .name property matching (MATCHES %@) the current selectedCategory!.name.
    // 6. Then we need to add this predicate to the request (request.predicate = predicate).
    // 7. Add another parameter to the loadItems() method, called predicate which is a search query that we want to make in order to load up our items. It will be of data type NSPredicate.
    // Method with Default Value listed inside loadItems(): = Item.fetchRequest() in case not parameter passed in (see viewDidLoad).
    // NSPredicate? Optional b/c
    func loadPhotos(with request: NSFetchRequest<Photo> = Photo.fetchRequest(), predicate: NSPredicate? = nil) {
        // R of CRUD = READ. Fetching items is "READ"

        print("")
        print("Are we here?")
        print("")

        // In order to only display filtered selected category results we need to create a predicate
        let predicateLat = NSPredicate(format: "parentPin.latitude MATCHES &@", (selectedPin?.latitude)!)
        let predicateLong = NSPredicate(format: "parentPin.longitude MATCHES %@", (selectedPin?.longitude)!)
        let pinPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLat, predicateLong])

        request.predicate = pinPredicate

        // our app has to speak to the context before we can speak to our persistantContainer
        // we want to fetch our current request, which is basically a blank request that returns everything in our persistantContainer, it can throw an error so put it inside a do-try-catch statement.
        do {
            // fetch(T) returns NSFetchRequestResult, which is an array of objects / of 'Items' that is stored in our persistantContainer
            // save results in the itemArray which is what was used to load up the tableView.
            // TRY using our context to '.fetch' these results from our persistent store ('request')
            photoArray = try context.fetch(request)
        } catch {
            print("loadItems(): Error fetching data from context \(error)")
        }
//        tableView.reloadData()
    }

}








