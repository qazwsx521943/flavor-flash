//
//  FFTabConfig.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import Foundation

enum TabItems: Int, CaseIterable {
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
