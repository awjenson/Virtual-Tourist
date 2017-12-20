/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
	
import UIKit


class Flickr {

    // MARK: Shared Instance

    class func sharedInstance() -> Flickr {
        struct Singleton {
            static var sharedInstance = Flickr()
        }
        return Singleton.sharedInstance
    }


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

                    if let image = UIImage(data: imageData) {
                        flickrPhoto.thumbnail = image
                        print("Photos to be displayed: \(String(describing: flickrPhoto.thumbnail))")
                        // Append photos to array of FlickrPhoto
                        flickrPhotos.append(flickrPhoto)
                    }
                }
                print("flickrPhotos: \(flickrPhotos.count)")

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

    // MARK: Helper for Creating a URL from Parameters

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


//    // MARK: Flickr API
//
//    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject]) {
//
//        // create session and request
//        let session = URLSession.shared
//        // Input: URL
//        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
//
//        // create network request
//        let task = session.dataTask(with: request) { (data, response, error) in
//
//            // if an error occurs, print it and re-enable the UI
//            func displayError(_ error: String) {
//                print(error)
//                performUIUpdatesOnMain {
//
//                    print("display an UI alert")
//                }
//            }
//
//            /* GUARD: Was there an error? */
//            guard (error == nil) else {
//                displayError("There was an error with your request: \(String(describing: error))")
//                return
//            }
//
//            /* GUARD: Did we get a successful 2XX response? */
//            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
//                displayError("Your request returned a status code other than 2xx!")
//                return
//            }
//
//            /* GUARD: Was there any data returned? */
//            guard let data = data else {
//                displayError("No data was returned by the request!")
//                return
//            }
//
//            // parse the data
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//            } catch {
//                displayError("Could not parse the data as JSON: '\(data)'")
//                return
//            }
//
//            /* GUARD: Did Flickr return an error (stat != ok)? */
//            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
//                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
//                return
//            }
//
//            /* GUARD: Is "photos" key in our result? */
//            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
//                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
//                return
//            }
//
//            /* GUARD: Is "pages" key in the photosDictionary? */
//            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
//                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
//                return
//            }
//
//            // pick a random page!
//            let pageLimit = min(totalPages, 40)
//            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
//            self.displayImageFromFlickrBySearch(methodParameters, withPageNumber: randomPage)
//        }
//
//        // start the task!
//        task.resume()
//    }
//
//
//    // What do we do here???
//
//    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject], withPageNumber: Int) {
//
//        // add the page to the method's parameters
//        var methodParametersWithPageNumber = methodParameters
//        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
//
//        // create session and request
//        let session = URLSession.shared
//        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
//
//        // create network request
//        let task = session.dataTask(with: request) { (data, response, error) in
//
//            // if an error occurs, print it and re-enable the UI
//            func displayError(_ error: String) {
//                print(error)
//                performUIUpdatesOnMain {
//
//                    print("create an UI alert")
//                }
//            }
//
//            /* GUARD: Was there an error? */
//            guard (error == nil) else {
//                displayError("There was an error with your request: \(error)")
//                return
//            }
//
//            /* GUARD: Did we get a successful 2XX response? */
//            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
//                displayError("Your request returned a status code other than 2xx!")
//                return
//            }
//
//            /* GUARD: Was there any data returned? */
//            guard let data = data else {
//                displayError("No data was returned by the request!")
//                return
//            }
//
//            // parse the data
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//            } catch {
//                displayError("Could not parse the data as JSON: '\(data)'")
//                return
//            }
//
//            /* GUARD: Did Flickr return an error (stat != ok)? */
//            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
//                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
//                return
//            }
//
//            /* GUARD: Is the "photos" key in our result? */
//            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
//                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
//                return
//            }
//
//            /* GUARD: Is the "photo" key in photosDictionary? */
//            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
//                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
//                return
//            }
//
//            if photosArray.count == 0 {
//                displayError("No Photos Found. Search Again.")
//                return
//            } else {
//                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
//                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
//                let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
//
//                /* GUARD: Does our photo have a key for 'url_m'? */
//                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
//                    displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
//                    return
//                }
//
//                // if an image exists at the url, set the image and title
//                let imageURL = URL(string: imageUrlString)
//                if let imageData = try? Data(contentsOf: imageURL!) {
//
//                    print("Success with collecting photos")
//                    // Call completiton handler to pass data and success to MapViewController so we can go to the next screen and display pictures
//
//
//                } else {
//                    displayError("Image does not exist at \(String(describing: imageURL))")
//                }
//            }
//        }
//
//        // start the task!
//        task.resume()
//    }


}








