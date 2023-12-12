//
//  CanvasStackItem.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/11.
//

import SwiftUI

@available(iOS 17.0, *)
struct CanvasStackItem<Content: View>: View {

	@Binding var stackItem: StackItem

	let content: Content

	var moveFront: () -> Void

	var delete: () -> Void

	@State private var longTapScale: CGFloat = 1

	@State var offset: CGSize = .zero
	@State var lastOffset: CGSize = .zero

	@State var scale: CGFloat = 1
	@State var lastScale: CGFloat = 1

	@State var rotation: Angle = .zero
	@State var lastRotation: Angle = .zero

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
			.offset(offset)
			.rotationEffect(rotation)
			.scaleEffect(scale < 0.4 ? 0.4 : scale)
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
						offset = CGSize(
							width: lastOffset.width + value.translation.width,
							height: lastOffset.height + value.translation.height
						)
					}
					.onEnded { value in
						lastOffset = offset
					}
			)
			.gesture(
				MagnifyGesture()
					.onChanged { value in
						scale = lastScale * value.magnification
					}
					.onEnded { value in
						lastScale = scale
					}
					.simultaneously(
						with: RotateGesture()
							.onChanged { value in
								rotation = lastRotation + value.rotation
							}
							.onEnded { value in
								lastRotation = rotation
							}
					)
			)
	}
}

//#Preview {
//    CanvasStackItem()
//}
