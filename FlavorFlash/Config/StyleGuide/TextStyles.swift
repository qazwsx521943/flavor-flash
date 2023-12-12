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

			Text("Padding")
				.captionStyle()
				.tagPaddingStyle()
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

struct CaptionBoldStyle: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.custom(FontStyle.fontNameBold.rawValue, size: 14))
	}
}

struct DetailBoldStyle: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.custom(FontStyle.fontNameBold.rawValue, size: 10))
	}
}

// MARK: - Padding Modifiers
struct TagPaddingStyle: ViewModifier {
	let backgroundColor: Color

	func body(content: Content) -> some View {
		content
			.padding(.horizontal, 10)
			.padding(.vertical, 6)
			.background(
				RoundedRectangle(cornerRadius: 10.0)
					.fill(backgroundColor)
			)
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

	func captionBoldStyle() -> some View {
		modifier(CaptionBoldStyle())
	}

	func detailBoldStyle() -> some View {
		modifier(DetailBoldStyle())
	}

	func tagPaddingStyle(backgroundColor: Color = .darkOrange) -> some View {
		modifier(TagPaddingStyle(backgroundColor: backgroundColor))
	}
}

// MARK: - Text Extension
extension Text {

	func prefixedWithSFSymbol(
		named name: String,
		height: CGFloat,
		tintColor color: Color = .black
	) -> some View {
		HStack {
			Image(systemName: name)
				.resizable()
				.scaledToFit()
				.frame(width: height, height: height)
			self
		}
//		.padding(.leading, 12)
	}

	func suffixWithSFSymbol(
		named name: String,
		height: CGFloat,
		tintColor color: Color = .black
	) -> some View {
		HStack {
			self
			Image(systemName: name)
				.resizable()
				.scaledToFit()
				.frame(width: height, height: height)
		}
		.padding(.horizontal, 8)
	}
}

#Preview {
    TextStyles()
}
