//
//  SignInEmailView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import SwiftUI
import PopupView

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
				VStack {
					NNLoadingIndicator()

					Text("Loading...")
						.titleStyle()
						.multilineTextAlignment(.center)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.transition(.push(from: .leading))
				.animation(Animation.spring, value: isAnimated)

			} else {
				Text(viewModel.state.navigationTitle)
					.titleStyle()
					.multilineTextAlignment(.center)
					.padding(.bottom, 80)


				TextField("email", text: $viewModel.email)
					.signInFields()

				SecureField("password", text: $viewModel.password)
					.signInFields()

				if viewModel.state == .signUp {
					TextField("name", text: $viewModel.displayName)
						.signInFields()
				}

				if viewModel.state == .signUp {
					TextField("username", text: $viewModel.username)
						.signInFields()
				}

				loginButton
			}
		}

		.frame(maxHeight: .infinity, alignment: .top)
		.padding(16)
		.navigationBarBackButtonHidden()
		.toolbar {
			NavigationBarBackButton()
		}
    }
}

extension EmailSignInView {
	// MARK: - Layout
	private var loginButton: some View {
		Button {
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
				withAnimation(.spring) {
					isAnimated = true
				}
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
				isAnimated = false
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
