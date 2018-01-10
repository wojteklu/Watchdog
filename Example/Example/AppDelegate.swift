//
//  AppDelegate.swift
//  Example
//
//  Created by Wojtek on 09/09/2015.
//  Copyright © 2015 Wojtek. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var watchdog: Watchdog!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        watchdog = Watchdog(threshold: 0.4, strictMode: true)
        
        return true
    }
}

