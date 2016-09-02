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
    let watchdog = Watchdog(threshold: 0.001, strictMode: false)

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
}

