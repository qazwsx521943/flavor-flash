//
//  FoodPrint.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/22.
//

import Foundation

struct FBFoodPrint: FBModelType, Equatable {
	var id: String
	let userId: String
	let username: String
	let restaurantId: String?
	let restaurantName: String?
	let frontCameraImageUrl: String
	let frontCameraImagePath: String
	let backCameraImageUrl: String
	let backCameraImagePath: String
	let description: String
	let category: String?
	let location: Location?
	let comments: [FBComment]?
	let likedBy: [String]?
	let createdDate: Date

	enum CodingKeys: String, CodingKey {
		case id
		case userId = "user_id"
		case username
		case restaurantId = "restaurant_id"
		case restaurantName = "restaurant_name"
		case frontCameraImageUrl = "front_camera_image_url"
		case frontCameraImagePath = "front_camera_image_path"
		case backCameraImageUrl = "back_camera_image_url"
		case backCameraImagePath = "back_camera_image_path"
		case description
		case category
		case location
		case comments
		case likedBy = "liked_by"
		case createdDate = "created_date"
	}

	init(
		id: String,
		userId: String,
		username: String,
		restaurantId: String? = nil,
		restaurantName: String? = nil,
		frontCameraImageUrl: String,
		frontCameraImagePath: String,
		backCameraImageUrl: String,
		backCameraImagePath: String,
		description: String,
		category: String? = nil, 
		location: Location? = nil,
		comments: [FBComment]? = nil,
		likedBy: [String]? = nil,
		createdDate: Date) {
		self.id = id
		self.userId = userId
		self.username = username
		self.restaurantId = restaurantId
		self.restaurantName = restaurantName
		self.frontCameraImageUrl = frontCameraImageUrl
		self.frontCameraImagePath = frontCameraImagePath
		self.backCameraImageUrl = backCameraImageUrl
		self.backCameraImagePath = backCameraImagePath
		self.description = description
		self.category = category
		self.location = location
		self.comments = comments
		self.likedBy = likedBy
		self.createdDate = createdDate
	}
}

extension FBFoodPrint {
	static func == (lhs: FBFoodPrint, rhs: FBFoodPrint) -> Bool {
		lhs.id == rhs.id
	}

	var getAllImagesURL: [String] {
		return [backCameraImageUrl, frontCameraImageUrl]
	}

	var relativeDateFormatter: RelativeDateTimeFormatter {
		let formatter = RelativeDateTimeFormatter()
		formatter.dateTimeStyle = .numeric
		formatter.unitsStyle = .short
		formatter.locale = Locale(identifier: "zh-TW")
		return formatter
	}

	var getRelativeTimeString: String {
		relativeDateFormatter.localizedString(for: createdDate, relativeTo: .now)
	}
}

// MARK: - Mock
extension FBFoodPrint {
	static let mockFoodPrint = FBFoodPrint(
		id: "1",
		userId: "1",
		username: "Godjj",
		restaurantId: "123",
		restaurantName: "我家",
		frontCameraImageUrl:
			"https://picsum.photos/200/300",
		frontCameraImagePath: "user/QzZRdN8ggVeMjryKjPMUjcljRJQ2/72E63EBF-3530-47A7-8581-052C371E1663.jpeg",
		backCameraImageUrl:
			"https://picsum.photos/200/300",
		backCameraImagePath: "user/QzZRdN8ggVeMjryKjPMUjcljRJQ2/5ECB61CA-F485-47A1-8C06-9B6C7BA7FFF9.jpeg",
		description: "好難吃",
		comments: [
			FBComment(id: "1", userId: "1", username: "mockUser", userProfileImage: "https://picsum.photos/200/300", comment: "你好聰明1", createdDate: .now),
			FBComment(id: "2", userId: "1", username: "mockUser", userProfileImage: "https://picsum.photos/200/300", comment: "你好聰明2", createdDate: .now),
			FBComment(id: "3", userId: "1", username: "mockUser", userProfileImage: "https://picsum.photos/200/300", comment: "你好聰明3", createdDate: .now)
		],
		createdDate: Date.now)
}
