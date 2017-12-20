//
//  UIViewExtension.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 12/14/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    // MARK: Alert Views
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
