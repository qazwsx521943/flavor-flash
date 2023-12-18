//
//  ProfileHeader.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/2.
//

import SwiftUI
import Kingfisher

struct ProfileHeader<Content: View, OverlayContent: View>: View {

	let avatarUrlString: String

	let displayName: String

	var content: Content?

	var overlayContent: OverlayContent?

	var body: some View {
		ZStack(alignment: .top) {
			RoundedRectangle(cornerRadius: 15)
				.fill(.gray.opacity(0.2))

			HStack(spacing: 50) {
				content
					.frame(width: 60)
			}
			.frame(maxWidth: .infinity)
			.padding(.horizontal, 50)
			.offset(y: 85)

			KFImage(URL(string: avatarUrlString))
				.placeholder{
					Image(systemName: "person.fill")
				}
				.resizable()
				.scaledToFill()
				.frame(width: 80, height: 80)
				.clipShape(Circle())
				.overlay(alignment: .bottomTrailing) {
					overlayContent
						.frame(width: 30, height: 30)
				}
				.offset(y: -40)
				.frame(maxWidth: .infinity)
				.overlay(alignment: .center) {
					Text(displayName)
						.bodyBoldStyle()
						.offset(y: 25)
				}
		}
		.frame(height: 150)
	}
}

extension ProfileHeader {
	// Custom initializer
	init(
		avatarUrlString: String,
		displayName: String,
		@ViewBuilder content: () -> Content,
		@ViewBuilder overlayContent: () -> OverlayContent) {
		self.avatarUrlString = avatarUrlString
		self.content = content()
		self.displayName = displayName
		self.overlayContent = overlayContent()
	}
}

// MARK: - Child View
struct ActivityItemDisplay: View {
	let title: String

	let count: Int

	var action: (() -> Void)?

	var body: some View {
		VStack(spacing: 10) {
			Text(title)
				.detailBoldStyle()
				.foregroundStyle(Color(uiColor: UIColor.lightGray))

			Text("\(count)")
				.bodyBoldStyle()
				.onTapGesture {
					action?()
				}
		}
	}
}

#Preview {
	ProfileHeader(avatarUrlString: "https://picsum.photos/200", displayName: "Jasssson") {
		ActivityItemDisplay(title: "foodprints", count: 8)
		ActivityItemDisplay(title: "badges", count: 8)
		ActivityItemDisplay(title: "friends", count: 8)
	} overlayContent: {
		Image(systemName: "pencil.circle.fill")
			.symbolRenderingMode(.multicolor)
			.font(.system(size: 30))
			.foregroundColor(.lightGreen)
	}
}
