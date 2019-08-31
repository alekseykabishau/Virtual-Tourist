//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Aleksey on 8/30/19.
//  Copyright © 2019 Aleksey Kabishau. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}
