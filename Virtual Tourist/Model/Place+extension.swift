//
//  Place+extension.swift
//  Virtual Tourist
//
//  Created by Aleksey on 8/26/19.
//  Copyright © 2019 Aleksey Kabishau. All rights reserved.
//

import MapKit

extension Place: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
