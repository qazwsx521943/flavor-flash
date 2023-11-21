//
//  SignInEmailView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import SwiftUI

@MainActor
class ViewModel: ObservableObject {
	@Published var email = ""
	@Published var password = ""
	@Published var displayName = ""

	var isValidEmail: Bool {
		EmailAddress(rawValue: email) != nil
	}

	func signUp() async throws {
		guard !email.isEmpty, !password.isEmpty else {
			throw FBAuthError.inputFieldEmpty
			return
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

struct SignInEmailView: View {
	@StateObject private var viewModel = ViewModel()
	@EnvironmentObject private var navigationModel: NavigationModel
    var body: some View {
		VStack {
			TextField("Email:", text: $viewModel.email)
				.signInFields()
			Divider()
			SecureField("Password", text: $viewModel.password)
				.signInFields()

			TextField("Name:", text: $viewModel.displayName)
				.signInFields()

			Button {
				Task {
					do {
						try await viewModel.signUp()
						navigationModel.showSignInModal = false
						navigationModel.showCategorySelectionModal = true
						return
					} catch {
						debugPrint(error)
					}

					do {
						try await viewModel.signIn()
						navigationModel.showSignInModal = false
						return
					} catch {
						debugPrint(error)
						return
					}
				}
			} label: {
				Text("Sign in")
			}
			.submitPressableStyle()
		}
		.padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
		.navigationTitle("Sign In With Email")
    }
}

#Preview {
	NavigationStack {
		SignInEmailView()
	}
}
