//
//  BackgroundModifiers.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/1.
//

import SwiftUI

struct RoundedRectangleBackgroundModifier: ViewModifier {

	let cornerRadius: CGFloat

	let gradient: Gradient

	func body(content: Content) -> some View {
		content
			.background(
				RoundedRectangle(cornerRadius: 10)
					.frame(height: 55)
					.foregroundStyle(
						LinearGradient(
							gradient: gradient,
							startPoint: .topLeading,
							endPoint: .bottomTrailing)
					)
			)
	}

	init(cornerRadius: CGFloat, gradient: [Color]) {
		self.cornerRadius = cornerRadius
		self.gradient = Gradient(colors: gradient)
	}
}

extension View {
	func withRoundedRectangleBackground(
		cornerRadius: CGFloat = 10.0,
		gradient: [Color] = [Color.red, Color.purple]
	) -> some View {
		modifier(
			RoundedRectangleBackgroundModifier(
				cornerRadius: cornerRadius,
				gradient: gradient))
	}
}
