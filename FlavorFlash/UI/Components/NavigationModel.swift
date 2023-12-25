//
//  NavigationModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI
import Combine

final class NavigationModel: ObservableObject {
	@Published var showSignInModal: Bool

	@Published var showCategorySelectionModal: Bool

    @Published var selectedTab: TabItems

    @Published var tabBarHidden: Bool

	@AppStorage("preferDarkMode") var preferDarkMode: Bool!

	init(
		showSignInModal: Bool = false,
		showCategorySelectionModal: Bool = false,
		selectedTab: TabItems = .foodPrint,
		tabBarHidden: Bool = false,
		preferDarkMode: Bool = false) {
		self.showSignInModal = showSignInModal
		self.showCategorySelectionModal = showCategorySelectionModal
		self.selectedTab = selectedTab
		self.tabBarHidden = tabBarHidden
		self.preferDarkMode = preferDarkMode
	}

	public func hideTabBar() {
        tabBarHidden = true
    }

	public func showTabBar() {
		tabBarHidden = false
	}

	public func setColorScheme(_ mode: ColorScheme) {
		self.preferDarkMode = mode == .dark
	}
}
