//
//  appConfig.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation

// MARK: - Tab Configs
enum TabItems: Int, Hashable, CaseIterable, Codable, Identifiable {
	var id: Int {
		rawValue
	}

	case home = 0
	case flavorFlash
	case community

	var title: String {
		switch self {
		case .home: return "Home"
		case .flavorFlash: return "FF"
		case .community: return "Community"
		}
	}

	var icon: String {
		switch self {
		case .home: return "home-icon"
		case .flavorFlash: return "camera-icon"
		case .community: return "community-icon"
		}
	}
}

// MARK: - Profile Configs
struct SettingItem: Identifiable, Hashable {
	let title: String
	let id = NSUUID().uuidString
}

struct AccountConfigs: Identifiable, Hashable {
	let title: String
	let id = NSUUID().uuidString
}

let settingConfigs: [SettingItem] = [
	.init(title: "Settings"),
	.init(title: "FoodPrint"),
	.init(title: "Style")
]

let accountConfigs: [AccountConfigs] = [
	.init(title: "Suspend"),
	.init(title: "Delete")
]

enum RestaurantCategory: String, CaseIterable, TagItem, Identifiable {
	var id: String {
		self.rawValue
	}

	case american
	case barbecue
	case brazilian
	case chinese
	case fast_food
	case french
	case greek
	case hamburger
	case indian
	case indonesian
	case japanese
	case korean
	case mediterranean
	case mexican
	case pizza
	case ramen
	case seafood
	case thai
	case turkish
	case steak
	case sushi
	case vietnamese

	var title: String { self.rawValue }

	var searchTag: String {
		switch self {
		case .steak: return rawValue + "_house"
		default: return rawValue + "_restaurant"
		}
	}
}

extension Array where Self.Element == RestaurantCategory {
	var toString: [String] {
		return self.map { $0.rawValue }
	}
}
