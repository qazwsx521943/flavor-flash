//
//  AuthenticationView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import SwiftUI

struct AuthenticationView: View {
	@StateObject private var authenticationViewModel = AuthenticationViewModel()

	@EnvironmentObject var navigationModel: NavigationModel

	var body: some View {
		VStack(spacing: 10) {

			signInWithAppleButton

			signInDivider

			signInWithEmailButton

			HStack {
				Spacer()

				registerLink
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
		.padding(40)
		.padding(.bottom, 50)
		.navigationTitle("Sign In")
		.toolbar(.hidden, for: .navigationBar)
	}
}

extension AuthenticationView {
	// MARK: - Layout
	private var signInWithAppleButton: some View {
		Button {
			Task {
				do {
					try await authenticationViewModel.signInWithApple()
					navigationModel.showSignInModal = false
				} catch {
					print(error)
				}
			}
		} label: {
			SignInWithAppleButtonView(type: .default, style: .white)
		}
		.frame(height: 55)
	}

	private var signInWithEmailButton: some View {
		NavigationLink {
			EmailSignInView(state: .signIn)
		} label: {
			emailSignInLabel
		}
	}

	private var emailSignInLabel: some View {
		Label("Sign in with Email", systemImage: "envelope.fill")
			.font(.system(size: 20))
			.foregroundStyle(.white)
			.frame(maxWidth: .infinity, maxHeight: 55)
			.withRoundedRectangleBackground()
	}

	private var signInDivider: some View {
		Divider()
			.frame(height: 2)
			.overlay(.gray)
			.padding()
			.overlay {
				Text("Continue with Email")
					.font(.caption)
					.padding(.horizontal, 10)
					.background(.black)
			}
	}

	private var registerLink: some View {
		NavigationLink {
			EmailSignInView(state: .signUp)
		} label: {
			Text("Doesn't have an account? Register")
				.font(.caption)
				.foregroundStyle(.white)
				.bold()
				.underline()
		}
	}
}

#Preview {
	NavigationStack {
		AuthenticationView()
	}
}
