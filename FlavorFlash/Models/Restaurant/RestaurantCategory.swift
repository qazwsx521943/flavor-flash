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

	var title: String {
		switch self {
		case .american: return "美式"
		case .barbecue: return "燒烤"
		case .brazilian: return "巴西"
		case .chinese: return "中餐"
		case .fast_food: return "速食"
		case .french: return "法式"
		case .greek: return "希腊"
		case .hamburger: return "漢堡"
		case .indian: return "印度"
		case .indonesian: return "印尼"
		case .japanese: return "日式料理"
		case .korean: return "韓國料理"
		case .mediterranean: return "地中海料理"
		case .mexican: return "墨西哥料理"
		case .pizza: return "披薩"
		case .ramen: return "拉麵"
		case .seafood: return "海鲜"
		case .thai: return "泰式料理"
		case .turkish: return "土耳其料理"
		case .steak: return "牛排"
		case .sushi: return "壽司"
		case .vietnamese: return "越南料理"
		}
	}

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
