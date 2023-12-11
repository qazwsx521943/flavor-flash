//
//  StackItem.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/11.
//

import SwiftUI

struct StackItem: Identifiable {
	var id = UUID().uuidString

	var view: AnyView

	// MARK: - For Gesture
	var offset: CGSize = .zero
	var lastOffset: CGSize = .zero

	var rotation: Angle = .zero
	var lastRotation: Angle = .zero

	var scale: CGFloat = 1.0
	var lastScale: CGFloat = 1.0
}
