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


class Flickr {

    // MARK: Shared Instance

    class func sharedInstance() -> Flickr {
        struct Singleton {
            static var sharedInstance = Flickr()
        }
        return Singleton.sharedInstance
    }

    // MARK: - Properties



    // MARK: Flickr API (URL Set-up)

    // Step 1 - CREATE URL (to find a random page)
    func searchFlickrForCoordinates(pin: Pin,completionSearchFlickrForCoordinates: @escaping (_ results: [[String: AnyObject]]?, _ errorString : String?) -> Void) {

        // This is creating the URL to set-up the GET Request for the Flickr API

        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: pinCoordinatesBBoxString(lat: pin.coordinate.latitude, long: pin.coordinate.longitude),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPage
        ]


        // STEP 2: SEND URL to FLICKR API (to find a random page)
        // Call taskForGETRandomPage and pass in parameters for URL Request to get Random Page
        taskForGETRandomPage(methodParameters as [String : AnyObject], completionGETRandomPageToParseJSON: {

            // Inside completionHandlerForGETRandomPageParseJSON.

            // Parse JSON data into Swift objects in order to get Random Page
            (data, error) in

            // Parse data and store in static property so that it is ready for use when we segue to PhotoAlbumViewController
            // Lastly, call completionHandler and pass true back to the MainMapViewController in order to segue to next VC that will display the photos.

            // **********************************************************************

            func sendError(_ error: String) {
                print("Error from taskForGETRandomPage: \(error)")
                completionSearchFlickrForCoordinates(nil, "Could not download photos from selected pin location.")
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


            // Pick a random page
            // Then call another taskForGETRandomPage with the random page in the URL
            // Then parse the JSON to display the photos from the random page

            // pick a random page!
            let randomPage = Int(arc4random_uniform(UInt32(totalPages))) + 1

            print("Total pages: \(totalPages)")
            print("Random page: \(randomPage)")


            // *** NEXT, Call next task to GET Photos

            self.taskForGETPhotosFromRandomPage(methodParameters as [String : AnyObject], withPageNumber: randomPage, completionGETPhotosFromRandomPageToParseJSON: { (data, error) in

                // Inside Completion.
                // Parse data and store in static property so that it is ready for use when we segue to PhotoAlbumViewController
                // Lastly, call completionHandler and pass true back to the MainMapViewController in order to segue to next VC that will display the photos.

                // **********************************************************************

                func sendError(_ error: String) {
                    print("Error from taskForGETRandomPage: \(error)")
                    completionSearchFlickrForCoordinates(nil, "Could not download photos from selected pin location.")
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
                guard let page = photosDictionary[Constants.FlickrResponseKeys.Page] as? Int, page != 0 else {
                    sendError("Cannot find key '\(Constants.FlickrResponseKeys.Page)' in \(photosDictionary)")
                    return
                }

                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                    sendError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                    return
                }

//                //////////////////////////////////////////////////////
//
//                var flickrPhotos = [FlickrPhoto]()
//
//                for photoObject in photoArray {
//                    guard let photoID = photoObject["id"] as? String,
//                        let farm = photoObject["farm"] as? Int ,
//                        let server = photoObject["server"] as? String ,
//                        let secret = photoObject["secret"] as? String else {
//                            break
//                    }
//                    let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret)
//
//                    guard let url = flickrPhoto.flickrImageURL(),
//                        let imageData = try? Data(contentsOf: url as URL) else {
//                            break
//                    }
//
//                    if let image = UIImage(data: imageData) {
//                        flickrPhoto.thumbnail = image
//                        flickrPhotos.append(flickrPhoto)
//                    }
//                }

                // send the photoArray data into the completionHandler, back to MainMapViewController
                print("completion is successful, return 'results'")
                completionSearchFlickrForCoordinates(photoArray, "")

            }) // taskForGETPhotosFromRandomPage
        }) // taskForGETRandomPage
    } // searchFlickrForCoordinates



//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////



    // MARK: - Flickr API Request

    // First GET Request: Used to Retrieve a Random Page (In Prep for Getting Photos)
    private func taskForGETRandomPage(_ methodParameters: [String: AnyObject], completionGETRandomPageToParseJSON:@escaping (_ data: Data?, _ error: NSError?) -> Void) {

        // This is the GET Request to the Flickr API

        // create session and request
        let session = URLSession.shared
        // flickr URL from Method Parameters: URL
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))

        print("URL request: \(request)")

        let task = session.dataTask(with: request) { data, response, error in

            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                // This completion handler will get call for any of the errors below
                completionGETRandomPageToParseJSON(nil, NSError(domain: "taskForGETRandomPage", code: 1, userInfo: userInfo))
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
            completionGETRandomPageToParseJSON(data, nil)
        }
        task.resume()
    } // End taskForGETRandomPage




    // Second GET Request: Used to Retrieve Photos from the Random Page

    private func taskForGETPhotosFromRandomPage(_ methodParameters: [String: AnyObject], withPageNumber: Int, completionGETPhotosFromRandomPageToParseJSON:@escaping (_ data: Data?, _ error: NSError?) -> Void) {

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
                completionGETPhotosFromRandomPageToParseJSON(nil, NSError(domain: "taskForGETPhotosFromRandomPageParseJSON", code: 1, userInfo: userInfo))
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

            completionGETPhotosFromRandomPageToParseJSON(data, nil)
        }
        // start the task!
        task.resume()
    }




















    // MARK: - HELPERS

    // MARK: Help for adding latitude and longitude to URL

    private func pinCoordinatesBBoxString(lat latitude: Double, long longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
//        let latitude = Constants.SelectedPin.latitude
//        let longitude = Constants.SelectedPin.longitude

        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)

        print("BBoxString: \(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)")
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

}








