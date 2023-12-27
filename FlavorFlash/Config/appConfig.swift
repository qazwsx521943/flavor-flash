//
//  appConfig.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation
import SwiftUI

// MARK: - Tab Configs
enum TabItems: Int, CaseIterable, Codable, Identifiable {
	var id: Int {
		rawValue
	}

	case foodPrint = 0
	case flavorFlash
	case liveStream
	case profile

	var title: String {
		switch self {
		case .foodPrint: return "FoodPrint"
		case .flavorFlash: return "FlavorFlash"
		case .liveStream: return "Stream"
		case .profile: return "Profile"
		}
	}

	var icon: String {
		switch self {
		case .foodPrint: return "star.bubble"
		case .flavorFlash: return "camera.fill"
		case .liveStream: return "video.fill"
		case .profile: return "person.fill"
		}
	}

	var rootView: AnyView {
		switch self {
		case .foodPrint: return AnyView(FoodPrintView())
		case .flavorFlash: return AnyView(FlavorFlashView())
		case .liveStream: return AnyView(LiveStreamView())
		case .profile: return AnyView(ProfileView())
		}
	}
}
