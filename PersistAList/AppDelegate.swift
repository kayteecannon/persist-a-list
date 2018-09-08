//
//  AppDelegate.swift
//  PersistAList
//
//  Created by Kaytee on 4/21/16.
//  Copyright © 2016 Kaytee. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let navController = window!.rootViewController as! UINavigationController
        let viewController = navController.topViewController as! MainListTableViewController
        viewController.coreDataStack = coreDataStack
        // Basic User Interface initialization
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
}

