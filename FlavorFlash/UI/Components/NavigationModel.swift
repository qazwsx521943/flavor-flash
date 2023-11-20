//
//  NavigationModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI
import Combine

final class NavigationModel: ObservableObject {
	@Published var showSignInModal: Bool = false
    @Published var selectedTab: TabItems = .home
    @Published var tabBarHidden: Bool = false

    func hideTabBar() {
        tabBarHidden = true
    }

}
