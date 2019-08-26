//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Aleksey on 8/24/19.
//  Copyright © 2019 Aleksey Kabishau. All rights reserved.
//

import UIKit
import MapKit

class Place: NSObject {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Place: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteInfoLabel: UILabel!
    
    var places = [Place]() {
        didSet {
            print(places.count)
        }
    }
    
    @IBAction func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        if !isEditing {
            if gestureRecognizer.state == .ended {
                print("long press")
                //TODO: - disable long press in edit mode
                let location = gestureRecognizer.location(in: mapView)
                let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
                let place = Place(latitude: coordinates.latitude, longitude: coordinates.longitude)
                places.append(place)
                mapView.addAnnotation(place)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        title = "Virtual Tourist"
        
        setMapPosition()
    }
    
    func saveMapPosition() {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "latitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "longitude")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "latitudeDelta")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "longitudeDelta")
        UserDefaults.standard.synchronize()
    }
    
    func setMapPosition() {
        if
            let latitude = UserDefaults.standard.value(forKey: "latitude") as? Double,
            let longitude = UserDefaults.standard.value(forKey: "longitude") as? Double,
            let latitudeDelta = UserDefaults.standard.value(forKey: "latitudeDelta") as? Double,
            let longitudeDelta = UserDefaults.standard.value(forKey: "longitudeDelta") as? Double {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            deleteInfoLabel.isHidden = !editing
        } else {
            deleteInfoLabel.isHidden = !editing
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else { return }
        let place = annotation as! Place
        
        if isEditing {
            //TODO: - remove from saved places
            print("\(place.coordinate) will be deleled")
            places.removeAll { $0 == place }
            mapView.removeAnnotation(annotation)
        } else {
            //TODO: - transition to Detail Screen
            print("Place \(place.coordinate) is selected")
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    
    //TODO: - purpose of viewForAnnotation method?
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapPosition()
    }
}
