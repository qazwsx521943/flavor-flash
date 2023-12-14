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

@MainActor
class AuthenticationViewModel: NSObject, ObservableObject {

	@Published var didSignInWithApple = false

	@Published var isFirstSignIn = false

	func signInWithApple() async throws {
		let signInAppleHelper = SignInAppleHelper()
		do {
			let tokens = try await signInAppleHelper.startSignInWithAppleFlow()
			let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
			let user = FBUser(auth: authDataResult)
			do {
				let existingUser = try await UserManager.shared.getUser(userId: user.id)
			} catch {
				try await UserManager.shared.createUser(user: user)
				isFirstSignIn = true
			}
		} catch {
			debugPrint("signIn with apple cancelled")
		}
		//		print(signInResult)
	}
}
