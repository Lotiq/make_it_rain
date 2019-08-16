//
//  AppDelegate.swift
//  Make It Rain
//
//  Created by Timothy on 4/13/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var enableAllOrientations = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Currency.initiate()
        return true
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        Currency.cachedImages.removeAllObjects()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if (enableAllOrientations == true){
            return UIInterfaceOrientationMask.allButUpsideDown
        }
        return UIInterfaceOrientationMask.portrait
    }


}

