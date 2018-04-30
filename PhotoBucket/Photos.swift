//
//  Photos.swift
//  PhotoBucket
//
//  Created by Praneet Chakraborty on 4/29/18.
//  Copyright © 2018 Praneet Chakraborty. All rights reserved.
//

import UIKit
import Firebase

class Photo: NSObject {
	var id: String?
	var caption: String
	var imageURL: String
	var created: Date!
	
	let captionKey = "caption"
	let urlKey = "imageURL"
	let createdKey = "created"
	
	init(caption: String, imageURL: String) {
		self.caption = caption
		self.imageURL = imageURL
		self.created = Date()
	}
	
	init(documentSnapshot: DocumentSnapshot) {
		self.id = documentSnapshot.documentID
		let data = documentSnapshot.data()!
		self.caption = data[captionKey] as! String
		self.imageURL = data[urlKey] as! String
		if data[createdKey] != nil {
			self.created = data[createdKey] as! Date
		}
	}
	
	var data: [String: Any] {
		return [captionKey: self.caption,
				urlKey: self.imageURL,
				createdKey: self.created]
	}
	
}
