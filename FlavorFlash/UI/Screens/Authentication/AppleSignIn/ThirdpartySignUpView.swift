//
//  ThirdpartySignUpView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/15.
//

import SwiftUI

struct ThirdpartySignUpView: View {
	@ObservedObject var viewModel: AuthenticationViewModel

	@ObservedObject var navigationModel: NavigationModel

	@State private var isAnimated = false

	var body: some View {
		VStack {
			if isAnimated {
				FFLottieView(lottieFile: "Loading")
					.frame(width: 200, height: 200)
					.transition(.push(from: .leading))
					.animation(Animation.spring, value: isAnimated)

			} else {
				Text("Register")
					.titleStyle()
					.multilineTextAlignment(.center)
					.padding(.bottom, 80)

				TextField("name", text: $viewModel.displayName)
					.signInFields()

				TextField("username", text: $viewModel.username)
					.signInFields()

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

	private var loginButton: some View {
		Button {
			Task {
				try? await viewModel.thirdPartySignUp()
				navigationModel.showSignInModal = false
				if viewModel.isFirstSignIn {
					navigationModel.showCategorySelectionModal = true
				}
			}
		} label: {
			Text("Create Account")
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
//
//#Preview {
//    ThirdpartySignUpView()
//}
