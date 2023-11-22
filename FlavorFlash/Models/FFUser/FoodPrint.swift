//
//  FoodPrint.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/22.
//

import Foundation

struct FoodPrint: Codable {
	let id: String
	let frontCameraImageUrl: String
	let frontCameraImagePath: String
	let backCameraImageUrl: String
	let backCameraImagePath: String
	let comment: String
	let createdDate: Date

	enum CodingKeys: String, CodingKey {
		case id
		case frontCameraImageUrl = "front_camera_image_url"
		case frontCameraImagePath = "front_camera_image_path"
		case backCameraImageUrl = "back_camera_image_url"
		case backCameraImagePath = "back_camera_image_path"
		case comment
		case createdDate = "created_date"
	}
}
