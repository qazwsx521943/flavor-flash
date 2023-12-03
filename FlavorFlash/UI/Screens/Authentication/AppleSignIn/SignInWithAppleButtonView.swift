//
//  SignInWithAppleButtonView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/29.
//

import SwiftUI
import AuthenticationServices

struct SignInWithAppleButtonView: View {
	public let type: ASAuthorizationAppleIDButton.ButtonType
	public let style: ASAuthorizationAppleIDButton.Style
	public let cornerRadius: CGFloat

	public init(
		type: ASAuthorizationAppleIDButton.ButtonType = .signIn,
		style: ASAuthorizationAppleIDButton.Style = .black,
		cornerRadius: CGFloat = 10
	) {
		self.type = type
		self.style = style
		self.cornerRadius = cornerRadius
	}

	public var body: some View {
		ZStack {
			Color.black.opacity(0.001)

			SignInWithAppleButtonViewRepresentable(
				type: type,
				style: style,
				cornerRadius: cornerRadius
			)
			.disabled(true)
		}
	}
}

private struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
	let type: ASAuthorizationAppleIDButton.ButtonType
	let style: ASAuthorizationAppleIDButton.Style
	let cornerRadius: CGFloat

	func makeUIView(context: Context) -> some UIView {
		let button = ASAuthorizationAppleIDButton(type: type, style: style)
		button.cornerRadius = cornerRadius
		return button
	}

	func updateUIView(_ uiView: UIViewType, context: Context) {

	}
}

#Preview {
	SignInWithAppleButtonView(type: .default, style: .black)
}
