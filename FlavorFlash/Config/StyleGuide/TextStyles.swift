//
//  TextStyles.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/6.
//

import SwiftUI

struct TextStyles: View {
	let englishTexts = [
		"Title", 
		"Body",
		"Body - Bold",
		"Caption",
		"Caption - Bold",
		"Caption tag"
	]

	let chineseTexts = [
		"標題",
		"內文",
		"內文 - 粗",
		"說明",
		"說明 - 粗",
		"說明 標籤"
	]

    var body: some View {
		VStack(spacing: 50) {

			Text("Text Styles")
				.titleStyle()
				.foregroundStyle(.lightGreen)
				.padding(.top, 100)

			HStack(spacing: 40) {
				textStyleGuideLayout(englishTexts)

				textStyleGuideLayout(chineseTexts)
			}

			Spacer()
		}
    }

	private func textStyleGuideLayout(_ textArray: [String]) -> some View {
		VStack(spacing: 15) {
			ForEach(textArray, id: \.self) { text in
				Text(text)
					.applyStyle(for: text)
			}
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

/// for text style guide preview
extension Text {
	@ViewBuilder
	func applyStyle(for text: String) -> some View {
		switch text {
		case "Title", "標題":
			self.titleStyle()
		case "Body", "內文":
			self.bodyStyle()
		case "Body - Bold", "內文 - 粗":
			self.bodyBoldStyle()
		case "Caption", "說明":
			self.captionStyle()
		case "Caption - Bold", "說明 - 粗":
			self.captionBoldStyle()
		case "Caption tag", "說明 - 標籤":
			self
				.captionStyle()
				.tagPaddingStyle(backgroundColor: .lightGreen)
		default:
			self
		}
	}
}
#Preview {
    TextStyles()
}
