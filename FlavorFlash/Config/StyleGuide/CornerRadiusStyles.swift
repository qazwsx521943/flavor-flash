//
//  CornerRadiusStyles.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/8.
//

import SwiftUI

struct CornerRadiusStyles: View {
	var body: some View {
		VStack {
			Text("CornerRadius Styles")

			Text("cornerRadius")
				.padding()
				.background(.orange)
				.roundedRectRadius(20)

		}
	}
}

struct RectangleRoundedRadius: ViewModifier {

	let cornerRadius: CGFloat

	func body(content: Content) -> some View {
		content
			.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
	}
}

extension View {
	public func roundedRectRadius(_ cornerRadius: CGFloat) -> some View {
		modifier(RectangleRoundedRadius(cornerRadius: cornerRadius))
	}
}

#Preview {
    CornerRadiusStyles()
}
