//
//  TextFieldModifiers.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import SwiftUI

struct ValidateModifier<T>: ViewModifier {
	let value: T

	let validator: (T) -> Bool

	func body(content: Content) -> some View {
		content
			.border(validator(value) ? .green : .red)
	}
}

struct SignInModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.bodyStyle()
			.padding()
			.background(Color.gray.opacity(0.4))
			.clipShape(.rect(cornerRadius: 10, style: .circular))
	}
}

extension TextField {
	func validateEmail(value: String, validator: @escaping (String) -> Bool) -> some View {
		modifier(ValidateModifier(value: value, validator: validator))
	}

	func signInFields() -> some View {
		modifier(SignInModifier())
	}
}

extension SecureField {
	func signInFields() -> some View {
		modifier(SignInModifier())
	}
}
