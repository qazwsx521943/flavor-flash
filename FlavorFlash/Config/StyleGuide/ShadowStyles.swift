//
//  ShadowStyles.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/6.
//

import SwiftUI

struct ShadowStyles: View {
    var body: some View {
		VStack {
			Text("Shadow Styles")
				.titleStyle()

			Color("AccentColor")
				.frame(width: 100, height: 100)
				.clipShape(RoundedRectangle(cornerRadius: 10.0))
				.lightWeightShadow()
		}
    }
}

// MARK: - Shadow Modifiers
struct LightWeightShadow: ViewModifier {
	@Environment(\.colorScheme) var colorScheme

	var shadowColor: Color {
		colorScheme == .light ? Color(.richBlack) : Color(.white)
	}

	func body(content: Content) -> some View {
		content
			.shadow(color: shadowColor, radius: 10, x: 5, y: 5)
	}
}

// MARK: - View Extension
extension View {
	public func lightWeightShadow() -> some View {
		modifier(LightWeightShadow())
	}
}

#Preview {
    ShadowStyles()
}
