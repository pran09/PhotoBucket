//
//  PhotoBucketViewController.swift
//  PhotoBucket
//
//  Created by Praneet Chakraborty on 4/29/18.
//  Copyright © 2018 Praneet Chakraborty. All rights reserved.
//

import UIKit
import Firebase

class PhotoBucketViewController: UIViewController {
	
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photo: Photo?
	var photoRef: DocumentReference?
	var photoListener: ListenerRegistration!
	
    override func viewDidLoad() {
		super.viewDidLoad()
		imageView.image = nil
        captionLabel.text = photo?.caption
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(showEditDialog))
        navigationItem.rightBarButtonItem?.title = "Edit Caption"
        activityIndicator.startAnimating()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		photoListener = photoRef?.addSnapshotListener({ (documentSnapshot, error) in
			if let error = error {
				print("Error getting the document: \(error.localizedDescription)")
				return
			}
			if !documentSnapshot!.exists {
				print("This document got deleted")
			}
			self.photo = Photo(documentSnapshot: documentSnapshot!)
			self.updateView()
		})
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		photoListener.remove()
	}
	
    @objc func showEditDialog() {
        let alertController = UIAlertController(title: "Edit", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Caption"
            textField.text = self.photo?.caption
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let editPhotoAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.default) { (action) in
            let captionTextField = alertController.textFields![0]
            self.photo?.caption = captionTextField.text!
			self.photoRef?.setData(self.photo!.data)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(editPhotoAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let imgString = photo?.imageURL {
            if let imgURL = URL(string: imgString) {
                DispatchQueue.global().async {
                    do {
                        let data = try Data(contentsOf: imgURL)
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(data: data)
                        }
                    } catch {
                        print("Error downloading image: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func updateView() {
        captionLabel.text = photo?.caption
    }
}
