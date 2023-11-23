//
//  EmailSignInViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/22.
//

import SwiftUI

@MainActor
class EmailSignInViewModel: ObservableObject {

	@Published var email = ""

	@Published var password = ""

	@Published var displayName = ""

	var isValidEmail: Bool {
		EmailAddress(rawValue: email) != nil
	}

	func signUp() async throws {
		guard
			!email.isEmpty,
			!password.isEmpty,
			!displayName.isEmpty
		else {
			throw FBAuthError.inputFieldEmpty
		}

		let userData = try await AuthenticationManager.shared.createUser(email: email, password: password)
		try await UserManager.shared.createNewUser(user: FFUser(auth: userData, displayName: displayName))
	}

	func signIn() async throws {
		guard !email.isEmpty, !password.isEmpty else {
			throw FBAuthError.inputFieldEmpty
		}

		let userData = try await AuthenticationManager.shared.signIn(email: email, password: password)
		debugPrint(userData)
	}
}
