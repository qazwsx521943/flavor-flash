//
//  Font.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import SwiftUI

struct DetailedInfoTitleModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.lineLimit(1)
			.font(.title2)
			.bold()
	}
}

extension Text {
	func detailedInfoTitle() -> some View {
		modifier(DetailedInfoTitleModifier())
	}

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
		.padding(.leading, 12)
	}
}
