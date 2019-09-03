//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Aleksey on 8/24/19.
//  Copyright © 2019 Aleksey Kabishau. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteInfoLabel: UILabel!
    
    var coreDataStack: CoreDataStack!
    
    var places = [Place]()
    
    @IBAction func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        if !isEditing {
            if gestureRecognizer.state == .ended {
                let location = gestureRecognizer.location(in: mapView)
                let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
                
                //TODO: - separate func for Place creation?
                let place = Place(context: coreDataStack.viewContext)
                place.latitude = coordinates.latitude
                place.longitude = coordinates.longitude
                
                //TODO: - add notification for user about issues
                try? coreDataStack.viewContext.save()
                
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
        loadPlaces()
    }
    
    func loadPlaces() {
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        //TODO: - consider Do-Catch, + sortDescriptor
        if let result = try? coreDataStack.viewContext.fetch(fetchRequest) {
            places = result
            mapView.addAnnotations(places)
        }
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
            //TODO: - separate func remove Place, user notification?
            coreDataStack.viewContext.delete(place)
            try? coreDataStack.viewContext.save()
            print("\(place.coordinate) will be deleled")
            places.removeAll { $0 == place }
            mapView.removeAnnotation(annotation)
        } else {
            let detailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            detailViewController.place = place
            detailViewController.coreDataStack = coreDataStack
            navigationController?.pushViewController(detailViewController, animated: true)
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    
    //TODO: - purpose of viewForAnnotation method?
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapPosition()
    }
}
