//
//  SignInEmailView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import SwiftUI

struct EmailSignInView: View {

	@StateObject private var viewModel = EmailSignInViewModel()

	@EnvironmentObject private var navigationModel: NavigationModel

    var body: some View {
		VStack {
			TextField("Email:", text: $viewModel.email)
				.signInFields()

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
		EmailSignInView()
	}
}
