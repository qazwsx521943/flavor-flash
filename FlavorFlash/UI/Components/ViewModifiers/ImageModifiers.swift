//
//  ImageModifiers.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import SwiftUI

extension Image {
	func photoStyle(
		withMaxWidth maxWidth: CGFloat = .infinity,
		withMaxHeight maxHeight: CGFloat = 300
	) -> some View {
		self
			.resizable()
			.scaledToFill()
			.frame(maxWidth: maxWidth, maxHeight: maxHeight)
			.clipped()
	}

	func resizeAndFill() -> some View {
		self
			.resizable()
			.scaledToFill()
	}
}
