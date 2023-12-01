//
//  Border.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import SwiftUI

struct BorderModifier: ViewModifier {
	let borderColor: Color
	let borderWidth: CGFloat

	func body(content: Content) -> some View {
		content
			.border(borderColor, width: borderWidth)
	}

	init(_ borderColor: Color, width: CGFloat) {
		self.borderColor = borderColor
		self.borderWidth = width
	}
}

extension View {
	func withBorder(_ color: Color, width: CGFloat = 2) -> some View {
		modifier(BorderModifier(color, width: width))
	}
}
