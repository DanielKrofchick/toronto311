//
//  AppDelegate.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-28.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import CoreData
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DataController.shared.load {
            os_log("data-loaded", log: .app, type: .info)
        }

        os_log("documents-directory: %@", log: .app, type: .info, NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])

        return true
    }
}
