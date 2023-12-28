//
//  LikeButton.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/3.
//

import SwiftUI

struct LikeButton: View {

	@Binding var isLiked: Bool

	var frame: CGSize = CGSize(width: 30, height: 30)

	var action: (() -> Void)?

	var body: some View {
		HStack {
			Button {
				action?()
				isLiked.toggle()
			} label: {
				ZStack {
					Image(systemName: isLiked ? "heart.fill" : "heart")
						.foregroundColor(isLiked ? Color.pink : Color.primary)
						.animation(.interpolatingSpring(stiffness: 170, damping: 15), value: isLiked)

					Circle()
						.strokeBorder(lineWidth: isLiked ? 0 : 35)
						.animation(.easeInOut(duration: 0.5).delay(0.1), value: isLiked)
						.frame(width: frame.width, height: frame.height, alignment: .center)
						.foregroundColor(Color(.systemPink))
						.hueRotation(.degrees(isLiked ? 300 : 200))
						.scaleEffect(isLiked ? 1.3 : 0)
						.animation(.easeInOut(duration: 0.5), value: isLiked)
				}
			}
		}
	}
}

#Preview {
	LikeButton(isLiked: .constant(false))
}
