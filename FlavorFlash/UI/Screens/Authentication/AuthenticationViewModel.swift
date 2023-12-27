//
//  AuthenticationViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/29.
//

import Foundation
import SwiftUI
import CryptoKit
import AuthenticationServices
import OSLog

@MainActor
class AuthenticationViewModel: NSObject, ObservableObject {

	@EnvironmentObject var navigationModel: NavigationModel

	@Published var isFirstSignIn = false

	@Published var showThirdPartySignUp = false

	@Published var appleSignUpUser: FBUser?

	@Published var username: String = ""

	@Published var displayName: String = ""

	func signInWithApple() async throws {
		let signInAppleHelper = SignInAppleHelper()
		do {
			let tokens = try await signInAppleHelper.startSignInWithAppleFlow()
			let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
			appleSignUpUser = FBUser(auth: authDataResult)
			guard let appleSignUpUser else { return }
			do {
				_ = try await UserManager.shared.getUser(userId: appleSignUpUser.id)
			} catch {
				isFirstSignIn = true
				guard let email = authDataResult.email else { return }
				let newUser = FBUser(auth: authDataResult, displayName: "Anonymous", username: email)
				try await UserManager.shared.createUser(user: newUser)
				try await UserManager.shared.setRestaurantCategories(userId: newUser.id, categories: RestaurantCategory.allCases.toString)
			}

		} catch {
			debugPrint("signIn with apple cancelled")
		}
	}

	func thirdPartySignUp() async throws {
		guard appleSignUpUser != nil else { return }

		guard
			!username.isEmpty,
			!displayName.isEmpty
		else {
			return
		}

		appleSignUpUser?.displayName = displayName
		appleSignUpUser?.username = username
		guard let appleSignUpUser else { return }

		try await UserManager.shared.createUser(user: appleSignUpUser)
		showThirdPartySignUp.toggle()
	}
}

fileprivate let logger = Logger(subsystem: "ios22-jason.FlavorFlash", category: "AuthenticationModel")
