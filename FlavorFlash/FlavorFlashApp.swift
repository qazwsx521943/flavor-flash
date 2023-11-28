//
//  FlavorFlashApp.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI
import FirebaseCore
import GooglePlaces

@main
struct FlavorFlashApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	@StateObject private var navigationModel = NavigationModel()
	@StateObject private var userStore = UserStore()

	@Environment(\.scenePhase) private var scenePhase

	init() {
		let env = {
#if DEBUG
			return DebugENV()
#else
			return ProdENV()
#endif
		}()

		FirebaseApp.configure()
		GMSPlacesClient.provideAPIKey(env.GOOGLE_MAP_API_KEY)
	}

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
		.onChange(of: scenePhase) { newValue in
			if newValue == .background {
				debugPrint("app is in the background!!!")
			}
			debugPrint("Current App Cycle", newValue)
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
