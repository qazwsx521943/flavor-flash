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
