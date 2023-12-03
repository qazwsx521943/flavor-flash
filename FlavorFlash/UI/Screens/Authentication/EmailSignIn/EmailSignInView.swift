//
//  SignInEmailView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import SwiftUI

struct EmailSignInView: View {

	@StateObject private var viewModel: EmailSignInViewModel

	@EnvironmentObject private var navigationModel: NavigationModel

	@State private var isAnimated: Bool = false

	init(state: EmailSignInViewModel.State) {
		_viewModel = StateObject(wrappedValue: EmailSignInViewModel(state: state))
	}

    var body: some View {
		VStack {
			if isAnimated {
				Circle()
					.stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
					.fill(.blue)
					.frame(width: 200, height: 200)
					.overlay(alignment: .center, content: {
						Text("Signing Up...")
							.font(.headline)
							.bold()
					})
					.transition(.push(from: .leading))
					.animation(Animation.spring, value: isAnimated)

			} else {
				TextField("Email:", text: $viewModel.email)
					.signInFields()

				SecureField("Password", text: $viewModel.password)
					.signInFields()

				if viewModel.state == .signUp {
					TextField("Name:", text: $viewModel.displayName)
						.signInFields()
				}

				loginButton
			}
		}
		.padding(16)
		.navigationTitle(viewModel.state.navigationTitle)
    }
}

extension EmailSignInView {
	// MARK: - Layout
	private var loginButton: some View {
		Button {
			withAnimation(.spring) {
				isAnimated = true
			}
			emailLogin()
		} label: {
			Text(viewModel.state.rawValue.uppercased())
				.bold()
				.foregroundStyle(.white)
		}
		.frame(
			maxWidth: isAnimated ? 50 : 300,
			maxHeight: 55)
		.withRoundedRectangleBackground()
		.padding(.top, 32)
	}
}

extension EmailSignInView {
	// MARK: - Functions
	private func emailLogin() {
		Task {
			do {
				try await viewModel.signUp()
				isAnimated = false
				navigationModel.showSignInModal = false
				navigationModel.showCategorySelectionModal = true
				return
			} catch {
				debugPrint(error)
			}

			do {
				try await viewModel.signIn()
				isAnimated = false
				navigationModel.showSignInModal = false
				return
			} catch {
				debugPrint(error)
				return
			}
		}
	}
}

#Preview {
	NavigationStack {
		EmailSignInView(state: .signUp)
	}
}

#Preview {
	NavigationStack {
		EmailSignInView(state: .signIn)
	}
}
