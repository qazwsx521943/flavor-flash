//
//  FlavorFlashApp.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI

@main
struct FlavorFlashApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	@StateObject private var navigationModel = NavigationModel()
	@StateObject private var userStore = UserStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
				.onAppear {
					let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()

					navigationModel.showSignInModal = authUser == nil
				}
				.fullScreenCover(isPresented: $navigationModel.showSignInModal) {
					NavigationStack {
						AuthenticationView()
					}
				}
				.fullScreenCover(isPresented: $navigationModel.showCategorySelectionModal) {
					RestaurantCategoryView()
				}
				.environmentObject(navigationModel)
				.environmentObject(userStore)
        }
    }
}

class UserStore: ObservableObject {
	@Published var currentUser: FFUser?

	func setCurrentUser(_ user: FFUser) {
		debugPrint("current user set to : \(user.displayName)")
		self.currentUser = user
	}
}
