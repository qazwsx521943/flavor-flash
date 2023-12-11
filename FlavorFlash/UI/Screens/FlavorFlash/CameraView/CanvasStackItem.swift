//
//  CanvasStackItem.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/11.
//

import SwiftUI

struct CanvasStackItem<Content: View>: View {

	@Binding var stackItem: StackItem

	let content: Content

	var moveFront: () -> Void

	var delete: () -> Void

	@State private var longTapScale: CGFloat = 1

	init(
		stackItem: Binding<StackItem>,
		@ViewBuilder content: @escaping () -> Content,
		moveFront: @escaping () -> (),
		delete: @escaping () -> ()) {
		self._stackItem = stackItem
		self.content = content()
		self.moveFront = moveFront
		self.delete = delete
	}

    var body: some View {
		content
			.offset(stackItem.offset)
			.rotationEffect(stackItem.rotation)
			.scaleEffect(stackItem.scale < 0.4 ? 0.4 : stackItem.scale)
			.scaleEffect(longTapScale)
			.onTapGesture(count: 2) {
				delete()
			}
			.onLongPressGesture(minimumDuration: 0.3, perform: {
				UIImpactFeedbackGenerator(style: .light).impactOccurred()
				moveFront()
				withAnimation(.easeInOut) {
					longTapScale = 1.2
				}
				withAnimation(.easeInOut.delay(0.1)) {
					longTapScale = 1
				}
			})
			.gesture(
				DragGesture()
					.onChanged { value in
						stackItem.offset = CGSize(
							width: stackItem.lastOffset.width + value.translation.width,
							height: stackItem.lastOffset.height + value.translation.height
						)
					}
					.onEnded { value in
						stackItem.lastOffset = stackItem.offset
					}
			)
    }
}

//#Preview {
//    CanvasStackItem()
//}
