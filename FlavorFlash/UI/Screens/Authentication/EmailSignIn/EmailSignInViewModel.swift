//
//  EmailSignInViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/22.
//

import SwiftUI

@MainActor
class EmailSignInViewModel: ObservableObject {

	enum State: String {
		case signUp = "Sign Up"
		case signIn = "Sign In"

		var navigationTitle: String {
			switch self {
			case .signIn: return "Sign In With Email"
			case .signUp: return "Sign Up With Email"
			}
		}
	}

	let state: State

	@EnvironmentObject var userStore: UserStore

	@Published var email = ""

	@Published var password = ""

	@Published var displayName = ""

	init(state: State) {
		self.state = state
	}

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

		let currentUser = try await UserManager.shared.getUser(userId: userData.uid)

//		userStore.setCurrentUser(currentUser)
		debugPrint(userData)
	}
}
