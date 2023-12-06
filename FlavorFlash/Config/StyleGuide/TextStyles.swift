//
//  TextStyles.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/6.
//

import SwiftUI

struct TextStyles: View {
    var body: some View {
		VStack(spacing: 10) {
			Text("Title")
				.titleStyle()

			Text("標題")
				.titleStyle()

			Text("Body")
				.bodyStyle()

			Text("內文-中")
				.bodyStyle()

			Text("BodyBold")
				.bodyBoldStyle()

			Text("內文-粗")
				.bodyBoldStyle()

			Text("caption")
				.captionStyle()

			Text("說明")
				.captionStyle()
        }
    }
}

// MARK: - Font Family
enum FontStyle: String {
	case fontNameBold = "Futura-Bold"
	case fontNameMedium = "Futura-Medium"
}

// MARK: - Font ViewModifiers
struct TitleStyle: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.custom(FontStyle.fontNameBold.rawValue, size: 36))
	}
}

struct BodyStyle: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.custom(FontStyle.fontNameMedium.rawValue, size: 20))
	}
}

struct BodyBoldStyle: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.custom(FontStyle.fontNameBold.rawValue, size: 20))
	}
}

struct CaptionStyle: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.custom(FontStyle.fontNameMedium.rawValue, size: 14))
	}
}

struct DetailBoldStyle: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.custom(FontStyle.fontNameBold.rawValue, size: 10))
	}
}


// MARK: - View Extension
extension View {
	func titleStyle() -> some View {
		modifier(TitleStyle())
	}

	func bodyStyle() -> some View {
		modifier(BodyStyle())
	}

	func bodyBoldStyle() -> some View {
		modifier(BodyBoldStyle())
	}

	func captionStyle() -> some View {
		modifier(CaptionStyle())
	}

	func detailBoldStyle() -> some View {
		modifier(DetailBoldStyle())
	}
}

extension Text {
	func navigationStyle() -> Self {
		self.font(.custom(FontStyle.fontNameBold.rawValue, fixedSize: 20))
	}
}
#Preview {
    TextStyles()
}
