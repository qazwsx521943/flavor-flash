//
//  CanvasViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/11.
//

import SwiftUI

class CanvasViewModel: ObservableObject {
	@Published var stack: [StackItem] = []

	func addStackItem(_ uiImage: UIImage) {
		let image = Image(uiImage: uiImage)
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 150, height: 150)
		let stackItem = StackItem(view: AnyView(image))
		stack.append(stackItem)
	}
}
