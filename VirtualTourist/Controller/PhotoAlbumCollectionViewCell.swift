//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Andrew Jenson on 12/13/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

// Create a Custom Cell File
// Identifier = "FlickrCell"

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties

    // Give the cell control of its background color
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 10 : 0
        }
    }

    // MARK: - View Life Cycle
    override func awakeFromNib() {
         super.awakeFromNib()
        imageView.layer.borderColor = themeColor.cgColor
        isSelected = false
    }
}
