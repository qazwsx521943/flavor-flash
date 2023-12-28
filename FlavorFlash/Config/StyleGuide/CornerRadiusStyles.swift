//
//  CornerRadiusStyles.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/8.
//

import SwiftUI

struct CornerRadiusStyles: View {
	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		VStack {
			Text("CornerRadius Styles")
				.titleStyle()
				.foregroundStyle(.lightGreen)
				.padding(.top, 100)

			VStack(spacing: 20) {
				Text("cornerRadius 10")
					.bodyStyle()
					.foregroundStyle(.white)
					.padding()
					.background(.lightGreen)
					.roundedRectRadius(10)

				Text("cornerRadius 20")
					.bodyStyle()
					.foregroundStyle(.white)
					.padding()
					.background(.lightGreen)
					.roundedRectRadius(20)

				Text("cornerRadius 30")
					.bodyStyle()
					.foregroundStyle(.white)
					.padding()
					.background(.lightGreen)
					.roundedRectRadius(30)

				Text("cornerRadius 40")
					.bodyStyle()
					.foregroundStyle(.white)
					.padding()
					.background(.lightGreen)
					.roundedRectRadius(40)
			}

			Spacer()
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
