//
//  ButtonModifiers.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import SwiftUI

struct FormSubmitButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.title2)
			.padding(.horizontal, 30)
			.padding(.vertical, 8)
			.foregroundColor(.primary)
			.overlay(
				RoundedRectangle(cornerRadius: 8)
					.stroke(.black, lineWidth: 1.5)
			)
			.scaleEffect(configuration.isPressed ? 0.9 : 1.0)
	}
}

extension View {
	func submitPressableStyle() -> some View {
		buttonStyle(FormSubmitButtonStyle())
	}
}
