//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 12/13/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
