//
//  DetailViewController.swift
//  Virtual Tourist
//
//  Created by Aleksey on 8/26/19.
//  Copyright © 2019 Aleksey Kabishau. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newColletion: UIButton!
    
    var place: Place!
    var coreDataStack: CoreDataStack!
    
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    @IBAction func managePhotos(_ sender: UIButton) {
        if isEditing {
            print("Delete Selected Photos")
        } else {
            print("Get New Colletion")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        addAnnotation(for: place)

    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        configureUI()
    }
    
    func configureUI() {
        if isEditing {
            newColletion.setTitle("Remove Selected Photos", for: .normal)
        } else {
            newColletion.setTitle("Get New Collection", for: .normal)
        }
    }
    
    //TODO: - Set Title to place name
    func addAnnotation(for place: Place) {
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 50000.0, longitudinalMeters: 50000.0)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(place)
    }
}
