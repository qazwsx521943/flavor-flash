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


	func signInWithApple() async throws {
		let signInAppleHelper = SignInAppleHelper()
		let tokens = try await signInAppleHelper.startSignInWithAppleFlow()
		//		print(signInResult)
		let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
		let user = FFUser(auth: authDataResult)
		try await UserManager.shared.createNewUser(user: user)
	}
}



