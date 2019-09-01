//
//  Flickr.swift
//  Virtual Tourist
//
//  Created by Aleksey on 9/1/19.
//  Copyright © 2019 Aleksey Kabishau. All rights reserved.
//

import UIKit

class FlickrPhoto {
    let id: String
    let farm: Int
    let server: String
    let secret: String
    var image: UIImage?
    
    init(id: String, farm: Int, server: String, secret: String) {
        self.id = id
        self.farm = farm
        self.server = server
        self.secret = secret
    }
    
    func imageURL(_ size: String = "m") -> URL? {
        if let url = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size).jpg") {
            return url
        }
        return nil
    }
}

