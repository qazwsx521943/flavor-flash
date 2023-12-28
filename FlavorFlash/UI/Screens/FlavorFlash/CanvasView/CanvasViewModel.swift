//
//  CanvasViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/11.
//

import SwiftUI

class CanvasViewModel: NSObject, ObservableObject {
	@Published var stack: [StackItem] = []

	public func addStackItem(_ uiImage: UIImage) {
		let image = Image(uiImage: uiImage)
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 150, height: 150)
		let stackItem = StackItem(view: AnyView(image))
		stack.append(stackItem)
	}

	public func addStackItem(_ anyView: AnyView) {
		let stackItem = StackItem(view: anyView)
		stack.append(stackItem)
	}

	private func getIndex(stackItem: StackItem) -> Int {
		return stack.firstIndex { $0.id == stackItem.id } ?? 0
	}

	public func moveToFront(_ stackItem: StackItem) {
		let currentIndex = getIndex(stackItem: stackItem)
		let lastIndex = stack.count - 1
		stack.insert(stack.remove(at: currentIndex), at: lastIndex)
	}

	public func deleteStackItem(_ stackItem: StackItem) {
		let currentIndex = getIndex(stackItem: stackItem)
		stack.remove(at: currentIndex)
	}
}
