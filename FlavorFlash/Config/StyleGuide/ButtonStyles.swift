//
//  ButtonStyles.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/6.
//

import SwiftUI

struct ButtonStyles: View {
    var body: some View {
		VStack {
			Text("Button Styles")
				.titleStyle()

			Button {

			} label: {
				Text("small primary")
			}
			.buttonStyle(SmallPrimaryButtonStyle())

			Button {

			} label: {
				Text("small primary")
			}
			.buttonStyle(SmallPrimaryButtonStyle())
			.disabled(true)

			Button {

			} label: {
				Text("Large primary")
			}
			.buttonStyle(LargePrimaryButtonStyle())

		}
    }
}

// MARK: - Custom ButtonStyles
struct SmallPrimaryButtonStyle: ButtonStyle {
	@Environment(\.colorScheme) var colorScheme

	@Environment(\.isEnabled) var isEnabled

	var backgroundColor: Color {
		colorScheme == .light ? Color(.middleYellow) : Color(.darkOrange)
	}

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.captionStyle()
			.padding(12.5)
			.background(RoundedRectangle(cornerRadius: 10.0).fill(backgroundColor))
			.scaleEffect(configuration.isPressed ? 0.9 : 1)
	}
}

struct LargePrimaryButtonStyle: ButtonStyle {
	@Environment(\.colorScheme) var colorScheme

	@Environment(\.isEnabled) var isEnabled

	var backgroundColor: Color {
		colorScheme == .light ? Color(.middleYellow) : Color(.darkOrange)
	}

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.bodyStyle()
			.padding(15)
			.background(RoundedRectangle(cornerRadius: 10.0).fill(backgroundColor))
			.scaleEffect(configuration.isPressed ? 0.9 : 1)
	}
}

#Preview {
    ButtonStyles()
}
