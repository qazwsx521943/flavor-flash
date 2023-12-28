//
//  OverlayModifiers.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/2.
//

import SwiftUI

struct OverlaySystemImageModifier: ViewModifier {
	@Environment(\.colorScheme) var colorScheme

	let systemName: String

	let size: CGSize

	let alignment: Alignment

	let color: Color

	let padding: CGFloat

	var action: (() -> Void)?

	func body(content: Content) -> some View {
		content
			.overlay(alignment: alignment) {
				Image(systemName: systemName)
					.resizable()
					.foregroundStyle(colorScheme == .dark ? .white : .black)
					.frame(width: size.width, height: size.height)
					.padding(padding)
					.onTapGesture {
						action?()
					}
			}
	}
}

extension View {
	func overlayWithSystemImage(
		systemName: String,
		size: CGSize = CGSize(width: 25, height: 25),
		alignment: Alignment = .center,
		color: Color = .white,
		padding: CGFloat = 16,
		action: (() -> Void)? = nil
	) -> some View {
		modifier(
			OverlaySystemImageModifier(
				systemName: systemName,
				size: size,
				alignment: alignment,
				color: color,
				padding: padding,
				action: action
			)
		)
	}
}
