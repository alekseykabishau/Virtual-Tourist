//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Aleksey on 9/1/19.
//  Copyright © 2019 Aleksey Kabishau. All rights reserved.
//

import Foundation
import MapKit

let key = "e64b3ac5f1aada47c6436406cd313196"

class FlickrAPI {
    
    //TODO: - refactor by using generic Result type Enum with Success and Error cases
    func searchFlickr(coordinate: CLLocationCoordinate2D, completion: @escaping ([[String: AnyObject]], Error?) -> Void) {
        
        guard let searchURL = searchURL(for: coordinate) else {
            // completion
            return
        }
        
        let request = URLRequest(url: searchURL)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    print(error)
                    completion([], error)
                }
            }
            
            guard let _ = response as? HTTPURLResponse, let data = data else {
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }
            
            do {
                guard
                    let resultDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
                    let stat = resultDictionary["stat"] as? String else {
                        DispatchQueue.main.async {
                            completion([], error)
                        }
                        return
                }
                
                switch stat {
                case "ok":
                    print("ready to parse")
                    let photoInfo = resultDictionary["photos"] as! [String: AnyObject]
                    let photos = photoInfo["photo"] as! [[String: AnyObject]]
                    DispatchQueue.main.async {
                        completion(photos, nil)
                    }
                case "fail":
                    print("fail")
                    //TODO: - handle error -> completion with error
                    return
                default:
                    print("unknown error")
                    //TODO: - handle error -> completion with error
                    return
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }.resume()
    }
    
    //TODO: - avoid using MapKit for this class
    //TODO: - make it more parameter driven
    func searchURL(for coordinate: CLLocationCoordinate2D) -> URL? {
        let page = Int.random(in: 1...100)
        let perPage = Int.random(in: 8...20)
        let stringURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&sort=date-posted-desc&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&per_page=\(perPage)&page=\(page)&format=json&nojsoncallback=1"
        return URL(string: stringURL)
    }
}
