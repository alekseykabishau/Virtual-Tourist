//
//  Photo+extension.swift
//  Virtual Tourist
//
//  Created by Aleksey on 9/1/19.
//  Copyright © 2019 Aleksey Kabishau. All rights reserved.
//

import Foundation

extension Photo {
    
    func imageURL(_ size: String = "m") -> URL? {
        // unwraping to silence warnings about string optionals
        if let server = server, let id = id, let secret = secret {
            return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size).jpg")
        } else {
            return nil
        }
    }
}
