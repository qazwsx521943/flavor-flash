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
	@UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

	@StateObject private var navigationModel = NavigationModel()

	@Environment(\.scenePhase) private var scenePhase

	@Environment(\.colorScheme) private var colorScheme

	init() {
		let preferDarkMode = UserDefaults.standard.object(forKey: "preferDarkMode") as? Bool

		if let preferDarkMode {
			_navigationModel = StateObject(wrappedValue: NavigationModel(preferDarkMode: preferDarkMode))
		}
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
							.preferredColorScheme(navigationModel.preferDarkMode ? .dark : .light)
					}
				}
				.preferredColorScheme(navigationModel.preferDarkMode ?? (colorScheme == .dark) ? .dark : .light)
				.environmentObject(navigationModel)

		}
		.onChange(of: scenePhase) { newValue in
			if newValue == .background {
				debugPrint("app is in the background!!!")
			}
			debugPrint("Current App Cycle", newValue)
		}
	}
}
