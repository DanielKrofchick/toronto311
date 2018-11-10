//
//  AppDelegate.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-28.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var dataController = DataController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dataController.load { [weak self] in
            print("data-loaded")
            self?.dataStuff()
        }
        
        return true
    }
    
    func dataStuff() {
        dataController.decode()
        
        if let viewController = window?.rootViewController as? ViewController {
            viewController.loadData()
        }
    }
}
