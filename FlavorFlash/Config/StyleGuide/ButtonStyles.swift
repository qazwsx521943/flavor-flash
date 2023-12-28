//
//  ButtonStyles.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/6.
//

import SwiftUI

struct ButtonStyles: View {
    var body: some View {
		VStack(spacing: 50) {
			Text("Button Styles")
				.titleStyle()
				.foregroundStyle(.lightGreen)
				.padding(.top, 100)

			VStack(spacing: 15) {
				Button {

				} label: {
					Text("small primary")
				}
				.buttonStyle(SmallPrimaryButtonStyle())

				Button {

				} label: {
					Text("small primary disabled")
				}
				.buttonStyle(SmallPrimaryButtonStyle())
				.disabled(true)

				Button {

				} label: {
					Text("Large primary")
				}
				.buttonStyle(LargePrimaryButtonStyle())

				Button {

				} label: {
					Image(systemName: "line.3.horizontal.decrease")
				}
				.buttonStyle(IconButtonStyle())
			}

			Spacer()
		}
    }
}

// MARK: - Custom ButtonStyles
struct SmallPrimaryButtonStyle: ButtonStyle {
	@Environment(\.colorScheme) var colorScheme

	@Environment(\.isEnabled) var isEnabled

	var backgroundColor: Color {
		colorScheme == .light ? Color(.darkGreen) : Color(.lightGreen)
	}

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.captionStyle()
			.foregroundStyle(.white)
			.padding(12.5)
			.background(
				RoundedRectangle(cornerRadius: 10.0).fill(backgroundColor)
					.brightness(isEnabled ? 0 : 0.2) 
			)
			.scaleEffect(configuration.isPressed 
						 ? 0.9
						 : 1
			)
	}
}

struct LargePrimaryButtonStyle: ButtonStyle {
	@Environment(\.colorScheme) var colorScheme

	@Environment(\.isEnabled) var isEnabled

	var backgroundColor: Color {
		colorScheme == .light ? Color(.darkGreen) : Color(.lightGreen)
	}

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.bodyStyle()
			.foregroundStyle(.white)
			.padding(15)
			.background(RoundedRectangle(cornerRadius: 10.0).fill(backgroundColor))
			.scaleEffect(configuration.isPressed ? 0.9 : 1)
	}
}

struct IconButtonStyle: ButtonStyle {
	@Environment(\.colorScheme) var colorScheme

	var backgroundColor: Color {
		colorScheme == .light ? Color(.darkGreen) : Color(.lightGreen)
	}

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.bodyBoldStyle()
			.foregroundStyle(.white)
			.padding(12)
			.background(
				Circle()
					.fill(
						configuration.isPressed 
						? backgroundColor.opacity(0.4)
						: backgroundColor.opacity(0.9))
			)
	}
}

#Preview {
    ButtonStyles()
}
