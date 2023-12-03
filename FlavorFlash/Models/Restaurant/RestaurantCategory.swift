//
//  RestaurantCategory.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/1.
//

import Foundation

enum RestaurantCategory: String, CaseIterable, Identifiable {
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
