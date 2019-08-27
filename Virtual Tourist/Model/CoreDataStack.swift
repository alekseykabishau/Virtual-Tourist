//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by Aleksey on 8/26/19.
//  Copyright © 2019 Aleksey Kabishau. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let persistentContainer: NSPersistentContainer
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    //TODO: - does it make sense to use lazy in this case?
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    //TODO: - is optional completion needed?
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
        completion?()
    }
}
