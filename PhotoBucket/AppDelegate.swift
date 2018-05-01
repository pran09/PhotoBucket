//
//  AppDelegate.swift
//  PhotoBucket
//
//  Created by Praneet Chakraborty on 4/17/18.
//  Copyright © 2018 Praneet Chakraborty. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		FirebaseApp.configure()
		GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
		GIDSignIn.sharedInstance().delegate = self
		
		let showLoginScreen = Auth.auth().currentUser == nil
			if showLoginScreen {
				showLoginViewController()
			} else {
				showNavigationController()
			}
		return true
	}
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		if let error = error {
			print("Error on signing in: \(error.localizedDescription)")
			return
		}
		
		guard let authentication = user.authentication else {return}
		let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
		Auth.auth().signIn(with: credential) { (user, error) in
			if let error = error {
				print("Error on sign in (second one): \(error.localizedDescription)")
				return
			}
		}
		print("You are now signed in with Google")
		handleLogin()
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
	}
	
	func showLoginViewController() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
	}
	
	func showNavigationController() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "NavigationController")
	}
	
	func handleLogin() {
		showNavigationController()
	}
	
	@objc func handleLogout() {
		do {
			try Auth.auth().signOut()
		} catch {
			print("Error on sign out: \(error.localizedDescription)")
		}
		showLoginViewController()
	}
}


extension UIViewController {
	var appDelegate: AppDelegate {
		get {
			return UIApplication.shared.delegate as! AppDelegate
		}
	}
}
