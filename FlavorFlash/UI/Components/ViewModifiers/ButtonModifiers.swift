//
//  ButtonModifiers.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import SwiftUI

struct SubmitLoadingButtonStyle: ButtonStyle {

	let scaleAmount: CGFloat

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.brightness(configuration.isPressed ? 0.6 : 0)
			.scaleEffect(configuration.isPressed ? 0.9 : 1)
	}
}

// MARK: - View Extension
extension View {
	func submitLoadingButtonStyle(scaleAmount: CGFloat = 0.9) -> some View {
		buttonStyle(SubmitLoadingButtonStyle(scaleAmount: scaleAmount))
	}
}
