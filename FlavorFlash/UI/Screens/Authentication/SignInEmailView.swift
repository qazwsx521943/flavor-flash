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

	func signUp() async throws {
		guard !email.isEmpty, !password.isEmpty else {
			return
		}

		let userData = try await AuthenticationManager.shared.createUser(email: email, password: password)
		try await UserManager.shared.createNewUser(user: FFUser(auth: userData, displayName: displayName))
	}

	func signIn() async throws {
		guard !email.isEmpty, !password.isEmpty else {
			return
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
				.padding()
				.background(Color.gray.opacity(0.4))
				.cornerRadius(10)
			Divider()
			SecureField("Password", text: $viewModel.password)
				.padding()
				.background(Color.gray.opacity(0.4))
				.cornerRadius(10)
			
			TextField("Name:" , text: $viewModel.displayName)
				.padding()
				.background(Color.gray.opacity(0.4))
				.cornerRadius(10)

			Button {
				Task {
					do {
						try await viewModel.signUp()
						navigationModel.showSignInModal = false
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
					}
				}
			} label: {
				Text("Sign in")
					.font(.headline)
					.background(.black)
					.foregroundStyle(.white)
					.frame(height: 55)
					.frame(maxWidth: .infinity)
					.cornerRadius(10)
			}
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
