//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Aleksey on 8/24/19.
//  Copyright © 2019 Aleksey Kabishau. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let coreDataStack = CoreDataStack(modelName: "VirtualTourist")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        coreDataStack.load {
            // set to nil for now
        }
        
        let navigationController = window?.rootViewController as! UINavigationController
        let mapViewController = navigationController.topViewController as! MapViewController
        mapViewController.coreDataStack = coreDataStack
        
        return true
    }
}

