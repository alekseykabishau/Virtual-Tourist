//
//  DetailViewController.swift
//  Virtual Tourist
//
//  Created by Aleksey on 8/26/19.
//  Copyright © 2019 Aleksey Kabishau. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newColletion: UIButton!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    var place: Place!
    var coreDataStack: CoreDataStack!
    
    let flickrAPI = FlickrAPI()
    var flickrPhotos = [Photo]()
    
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    @IBAction func managePhotos(_ sender: UIButton) {
        if isEditing {
            print("Delete Selected Photos")
            deletePhotos()
        } else {
            print("Get New Colletion")
            noImagesLabel.isHidden = true
            for photo in flickrPhotos {
                coreDataStack.viewContext.delete(photo)
            }
            try? coreDataStack.viewContext.save()
            flickrPhotos.removeAll()
            collectionView.reloadData()
            getPhotos(for: place)
        }
    }
    
    //TODO: - Add RefreshControl to get new collection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        guard let place = place else { return }
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "place == %@", place)
        fetchRequest.predicate = predicate
        
        if let result = try? coreDataStack.viewContext.fetch(fetchRequest) {
            flickrPhotos = result
            print("\(flickrPhotos.count) in array")
        }
        
        if flickrPhotos.count == 0 {
            getPhotos(for: place)
        }
        
        addAnnotation(for: place)

    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        collectionView.allowsMultipleSelection = editing
        
        // cleaning previously selected cells (if any) before entering editing mode
        collectionView.indexPathsForSelectedItems?.forEach({ (indexPath) in
            collectionView.deselectItem(at: indexPath, animated: false)
        })
        
        guard let indexPaths = collectionView?.indexPathsForVisibleItems else { return }
        
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
            cell.isEditing = editing
        }
        
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
    
    func getPhotos(for place: Place) {
        //TODO: - create type SearchResults with + and Error and use switch in func
        flickrAPI.searchFlickr(coordinate: place.coordinate) { (photos, error) in
            if error != nil {
                print("error getting photos from API")
            } else {
                print("found \(photos.count) photo objects")
                if photos.count == 0 {
                    self.noImagesLabel.isHidden = false
                }
                self.save(photos)
            }
            //TODO: - how to update photos one by one while they are loading?
            self.collectionView.reloadData()
        }
    }
    
    func save(_ searchResults: [[String: AnyObject]]) {
        for dictionary in searchResults {
            let photo = Photo(context: coreDataStack.viewContext)
            photo.id = dictionary["id"] as? String
            photo.farm = (dictionary["farm"] as? Int16)!
            photo.server = dictionary["server"] as? String
            photo.secret = dictionary["secret"] as? String
            
            flickrPhotos.append(photo)
            
            if let url = photo.imageURL() {
                print(url)
                
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        print(error ?? "")
                        return
                    }
                    DispatchQueue.main.async {
                        if let data = data {
                            photo.thumbImage = data
                        }
                        try? self.coreDataStack.viewContext.save()
                        print("saving image \(photo.thumbImage) in core data")
                        self.collectionView.reloadData()
                    }
                }.resume()
            }
            
            photo.place = place
            try? coreDataStack.viewContext.save()
            print("saving photo object \(photo.id) in core data")
        }
    }
    
    func deletePhotos() {
        if let selected = collectionView.indexPathsForSelectedItems {
            // sorting to avoid issue with removing wrong/not existing endexes
            let itemsToRemove = selected.map { $0.item }.sorted().reversed()
            print(itemsToRemove)
            for item in itemsToRemove {
                let photo = flickrPhotos[item]
                coreDataStack.viewContext.delete(photo)
                flickrPhotos.remove(at: item)
            }
            try? coreDataStack.viewContext.save()
            collectionView.deleteItems(at: selected)
        }
    }
}

extension DetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
            print("\(indexPath.item) is selected")
            //TODO: - open in full mode
        }
    }
}

extension DetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell
        let photo = flickrPhotos[indexPath.item]
        if let imageData = photo.thumbImage {
            cell.thumbnailImage.image = UIImage(data: imageData)
        }
        cell.isEditing = isEditing
        return cell
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = (view.frame.size.width) - paddingSpace
        let itemWidth = availableWidth / itemsPerRow
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    
    /* don't need because working with only one section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    */
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
