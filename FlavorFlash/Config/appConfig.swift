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
	case foodPrint
	case profile

	var title: String {
		switch self {
		case .home: return "Home"
		case .flavorFlash: return "FlavorFlash"
		case .foodPrint: return "FoodPrint"
		case .profile: return "Profile"
		}
	}

	var icon: String {
		switch self {
		case .home: return "house.fill"
		case .flavorFlash: return "camera.fill"
		case .foodPrint: return "rectangle.3.group.bubble.fill"
		case .profile: return "person.fill"
		}
	}
}
