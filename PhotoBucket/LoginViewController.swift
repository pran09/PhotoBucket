//
//  LoginViewController.swift
//  PhotoBucket
//
//  Created by Praneet Chakraborty on 4/29/18.
//  Copyright © 2018 Praneet Chakraborty. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {
	
	let rosefireRegistryToken = "d0725aa4-6520-4ce6-91b8-72f85fbaf22d"

    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    @IBOutlet weak var rosefireLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		GIDSignIn.sharedInstance().uiDelegate = self
		googleLoginButton.style = .wide
		
		
	}
    @IBAction func rosefireLogin(_ sender: Any) {
		Rosefire.sharedDelegate().uiDelegate = self
		Rosefire.sharedDelegate().signIn(registryToken: rosefireRegistryToken) { (error, result) in
			if let error = error {
				print("Error on Rosefire login: \(error.localizedDescription)")
				return
			}
			print("You are now signed in with Rosefire")
			Auth.auth().signIn(withCustomToken: result!.token, completion: self.loginCompletionCallback)
		}
    }
	
	func loginCompletionCallback(_ user: User?, _ error: Error?) {
		if let error = error {
			print("Error during log in: \(error.localizedDescription)")
			let ac = UIAlertController(title: "Login failed", message: error.localizedDescription, preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(ac, animated: true)
		} else {
			appDelegate.handleLogin()
		}
	}
}
