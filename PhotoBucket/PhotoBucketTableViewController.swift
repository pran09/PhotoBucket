//
//  PhotoBucketTableViewController.swift
//  PhotoBucket
//
//  Created by Praneet Chakraborty on 4/29/18.
//  Copyright © 2018 Praneet Chakraborty. All rights reserved.
//

import UIKit
import Firebase

class PhotoBucketTableViewController: UITableViewController {
	
	var photosRef: CollectionReference!
	var photosListener: ListenerRegistration!
	
	let photoCellIdentifier = "PhotoCell"
	let noPhotoCellIdentifier = "NoPhotosCell"
	let showDetailSegueIdentifier = "ShowDetailSegue"
	var photoBuckets = [Photo]()
	var showAllPhotos: Bool = true  //boolean is true if current mode is set to show all photos
	    
    override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Photo Bucket"
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(showActionMenu))
		photosRef = Firestore.firestore().collection("photos")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		photoBuckets.removeAll()
		loadAllPhotoBuckets()
	}
	
	func loadAllPhotoBuckets() {
		photosListener = photosRef.order(by: "created", descending: true).addSnapshotListener({ (querySnapshot, error) in
			guard let snapshot = querySnapshot else {
				print("Error fetching photos: \(String(describing: error?.localizedDescription))")
				return
			}
			snapshot.documentChanges.forEach({ (docChange) in
				if docChange.type == .added {
					print("New photo: \(docChange.document.data())")
					self.photoAdded(docChange.document)
				} else if docChange.type == .modified {
					print("Modified photo: \(docChange.document.data())")
					self.photoModified(docChange.document)
				} else if docChange.type == .removed {
					let photo = Photo(documentSnapshot: docChange.document)
					if photo.uid == Auth.auth().currentUser?.uid {
						print("Removed photo: \(docChange.document.data())")
						self.photoRemoved(docChange.document)
					}
				}
				self.photoBuckets.sort(by: { (p1, p2) -> Bool in
					return p1.created > p2.created
				})
			})
			self.tableView.reloadData()
		})
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		photosListener.remove()
	}
	
	func photoAdded(_ document: DocumentSnapshot) {
		let newPhoto = Photo(documentSnapshot: document)
		photoBuckets.append(newPhoto)
	}
	
	func photoModified(_ document: DocumentSnapshot) {
		let modifiedPhoto = Photo(documentSnapshot: document)
		
		for photo in photoBuckets {
			if photo.id == modifiedPhoto.id {
				photo.caption = modifiedPhoto.caption
				photo.imageURL = modifiedPhoto.imageURL
				break
			}
		}
	}
	
	func photoRemoved(_ document: DocumentSnapshot) {
		let removedPhoto = Photo(documentSnapshot: document)
		if removedPhoto.uid != Auth.auth().currentUser?.uid {return}
		for i in 0..<photoBuckets.count {
			if photoBuckets[i].id == removedPhoto.id {
				photoBuckets.remove(at: i)
				break
			}
		}
	}
	
	@objc func showAddDialog() {
		let alertController = UIAlertController(title: "Create a new Photo Bucket", message: "", preferredStyle: .alert)
		alertController.addTextField { (textField) in
			textField.placeholder = "Caption"
		}
		alertController.addTextField { (textField) in
			textField.placeholder = "Image URL (or blank)"
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let createPhotoAction = UIAlertAction(title: "Create", style: .default) { (action) in
			let captionTextField = alertController.textFields![0]
			let imageURLTextField = alertController.textFields![1]
			print("captionTextField = \(captionTextField.text!)")
			print("imageURLTextField = \(imageURLTextField.text!)")
			let newPhotoBucket = Photo(caption: captionTextField.text!, imageURL: imageURLTextField.text!, uid: (Auth.auth().currentUser?.uid)!)
			if imageURLTextField.text == "" {
				newPhotoBucket.imageURL = self.getRandomImageURL()
			}
			self.photosRef.addDocument(data: newPhotoBucket.data)
			self.tableView.reloadData()
		}
		alertController.addAction(cancelAction)
		alertController.addAction(createPhotoAction)
		present(alertController, animated: true, completion: nil)
	}
	
	@objc func showActionMenu() {
		let menu:UIAlertController = UIAlertController(title: "Photo Bucket Options", message: nil, preferredStyle: .actionSheet)
		
		let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
			print("Pressed cancel from the action menu")
		}
		menu.addAction(cancelButton)
		
		let addPhotoButton = UIAlertAction(title: "Add Photo", style: .default) { (action) in
			self.showAddDialog()
			self.tableView.reloadData()
		}
		menu.addAction(addPhotoButton)
		
		let editPhotoButton = UIAlertAction(title: "Edit", style: .default) { (action) in
			
		}
		let uidQuery = self.photosRef.whereField("uid", isEqualTo: Auth.auth().currentUser?.uid as Any)
		uidQuery.getDocuments { (querySnapshot, error) in
			if let error = error {
				print("Error finding query for edit button: \(error.localizedDescription)")
			}
			if (querySnapshot?.isEmpty)! {
				editPhotoButton.isEnabled = false
			} else {
				editPhotoButton.isEnabled = true
			}
		}
		
		menu.addAction(editPhotoButton)
		
		let showPhotosButton = UIAlertAction(title: "Show My Photos", style: .default) { (action) in
			if self.showAllPhotos { //show only my photos, do query
				let uidQuery = self.photosRef.whereField("uid", isEqualTo: Auth.auth().currentUser?.uid as Any)
				self.photoBuckets.removeAll()
				uidQuery.getDocuments(completion: { (querySnapshot, error) in
					if let error = error {
						print("Error getting documents from query: \(error.localizedDescription)")
					} else {
						querySnapshot?.documentChanges.forEach({ (docChange) in
							if docChange.type == .added {
								print("New query photo: \(docChange.document.data())")
								self.photoAdded(docChange.document)
							} else if docChange.type == .modified {
								print("Modified query photo: \(docChange.document.data())")
								self.photoModified(docChange.document)
							} else if docChange.type == .removed {
								print("Removed query photo: \(docChange.document.data())")
								self.photoRemoved(docChange.document)
							}
							self.photoBuckets.sort(by: { (p1, p2) -> Bool in
								return p1.created > p2.created
							})
						})
						self.tableView.reloadData()
					}
				})
				self.showAllPhotos = false
			} else {
				self.photoBuckets.removeAll()
				self.loadAllPhotoBuckets()
				self.showAllPhotos = true
			}
		}
		if !self.showAllPhotos {
			showPhotosButton.setValue("Show All Photos", forKey: "title")
		} else {
			showPhotosButton.setValue("Show My Photos", forKeyPath: "title")
			
		}
		menu.addAction(showPhotosButton)
		
		let signOutButton = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
			do {
				try Auth.auth().signOut()
				print("You are now signed out")
				self.appDelegate.showLoginViewController()
			} catch {
				print("Error on sign out: \(error.localizedDescription)")
			}
		}
		menu.addAction(signOutButton)
		
		self.present(menu, animated: true, completion: nil)
	}
	
	func getRandomImageURL() -> String {
		let testImages = ["https://upload.wikimedia.org/wikipedia/commons/0/04/Hurricane_Isabel_from_ISS.jpg",
						  "https://upload.wikimedia.org/wikipedia/commons/0/00/Flood102405.JPG",
						  "https://upload.wikimedia.org/wikipedia/commons/6/6b/Mount_Carmel_forest_fire14.jpg"]
		let randomIndex = Int(arc4random_uniform(UInt32(testImages.count)))
		return testImages[randomIndex];

	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		if photoBuckets.count == 0 {
			print("Don't allow editing mode at this time")
			super.setEditing(false, animated: animated)
		} else {
			super.setEditing(editing, animated: animated)
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return max(photoBuckets.count, 1)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell
		if photoBuckets.count == 0 {
			cell = tableView.dequeueReusableCell(withIdentifier: noPhotoCellIdentifier, for: indexPath)
		} else {
			cell = tableView.dequeueReusableCell(withIdentifier: photoCellIdentifier, for: indexPath)
			cell.textLabel?.text = photoBuckets[indexPath.row].caption
		}
		return cell
	}
	

	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		//return photoBuckets[indexPath.row].uid == Auth.auth().currentUser?.uid
		return photoBuckets.count > 0
	}

	
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let photoToDelete = photoBuckets[indexPath.row]
			if photoToDelete.uid == Auth.auth().currentUser?.uid {
				photosRef.document(photoToDelete.id!).delete()
			}
		}
	}
	
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == showDetailSegueIdentifier {
			if let indexPath = tableView.indexPathForSelectedRow {
				(segue.destination as! PhotoBucketViewController).photoRef = photosRef.document(photoBuckets[indexPath.row].id!)
			}
		}
	}
}
