//
//  FoodPrint.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/22.
//

import Foundation

struct FoodPrint: FBModelType {
	var id: String
	let userId: String
	let restaurantId: String?
	let frontCameraImageUrl: String
	let frontCameraImagePath: String
	let backCameraImageUrl: String
	let backCameraImagePath: String
	let description: String
	let category: String?
	let location: Location?
	let createdDate: Date

	enum CodingKeys: String, CodingKey {
		case id
		case userId = "user_id"
		case restaurantId = "restaurant_id"
		case frontCameraImageUrl = "front_camera_image_url"
		case frontCameraImagePath = "front_camera_image_path"
		case backCameraImageUrl = "back_camera_image_url"
		case backCameraImagePath = "back_camera_image_path"
		case description
		case category
		case location
		case createdDate = "created_date"
	}

	init(id: String, userId: String, restaurantId: String? = nil, 
		 frontCameraImageUrl: String, frontCameraImagePath: String, backCameraImageUrl: String, backCameraImagePath: String,
		 description: String, category: String? = nil, location: Location? = nil, createdDate: Date) {
		self.id = id
		self.userId = userId
		self.restaurantId = restaurantId
		self.frontCameraImageUrl = frontCameraImageUrl
		self.frontCameraImagePath = frontCameraImagePath
		self.backCameraImageUrl = backCameraImageUrl
		self.backCameraImagePath = backCameraImagePath
		self.description = description
		self.category = category
		self.location = location
		self.createdDate = createdDate
	}
}

extension FoodPrint {
	var getAllImagesURL: [String] {
		return [backCameraImageUrl, frontCameraImageUrl]
	}
}
