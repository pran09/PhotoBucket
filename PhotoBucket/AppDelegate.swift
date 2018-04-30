//
//  AppDelegate.swift
//  PhotoBucket
//
//  Created by Praneet Chakraborty on 4/17/18.
//  Copyright © 2018 Praneet Chakraborty. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
	
	var window: UIWindow?
	
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		FirebaseApp.configure()
		return true
	}
}

