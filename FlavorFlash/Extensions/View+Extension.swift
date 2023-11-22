//
//  View+Extension.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }

	func ignoreSafeArea() -> some View {
		self.modifier(IgnoresSafeArea())
	}
}

private struct IgnoresSafeArea: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 14.0, *) {
			content.ignoresSafeArea(.keyboard, edges: .bottom)
		} else {
			content
		}
	}
}
