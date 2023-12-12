//
//  ToggleStyles.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/6.
//

import SwiftUI

struct ToggleStyles: View {
	@State private var isOn = false

	var body: some View {
		VStack {
			Text("Toggle Styles")

			Toggle("toggle", isOn: .constant(true))
				.toggleStyle(PrimaryToggleStyle(isLabelHidden: true))

			Toggle("toggle", isOn: .constant(false))
				.toggleStyle(PrimaryToggleStyle(isLabelHidden: true))

			Toggle("toggle", isOn: $isOn)
				.toggleStyle(PrimaryToggleStyle(isLabelHidden: true))
		}
	}
}

// MARK: - Custom ToggleStyles

struct PrimaryToggleStyle: ToggleStyle {
	@Environment(\.colorScheme) var colorScheme

	let isLabelHidden: Bool
	let size: CGFloat

	var backgroundColor: Color {
		colorScheme == .light ? Color(.middleYellow) : Color(.lightGreen)
	}

	init(isLabelHidden: Bool = false, size: CGFloat = 20.0) {
		self.isLabelHidden = isLabelHidden
		self.size = size
	}

	func makeBody(configuration: Configuration) -> some View {
		return HStack {
			if !isLabelHidden {
				configuration.label
					.captionStyle()
			}

			Spacer()

			HStack(spacing: 10) {
				if configuration.isOn {
					Text("on")
						.detailBoldStyle()
						.frame(width: size, height: size)
				}

				Circle()
					.fill(.white)
					.frame(width: size, height: size)

				if !configuration.isOn {
					Text("off")
						.detailBoldStyle()
						.frame(width: size, height: size)
				}
			}
			.padding(8)
			.background(
				Capsule()
					.fill(configuration.isOn ? backgroundColor : Color(.shadowGray))
			)
		}.onTapGesture {
			withAnimation {
				configuration.$isOn.wrappedValue.toggle()
			}
		}
	}
}

#Preview {
    ToggleStyles()
}
