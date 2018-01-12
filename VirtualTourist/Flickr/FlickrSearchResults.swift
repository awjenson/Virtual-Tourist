//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 12/14/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

// A struct which wraps up a search term and the results found for that search.

import Foundation

struct FlickrSearchResults {
    let searchLat : Double
    let searchLong: Double
    let searchResults : [FlickrPhoto]
}



