//
//  ProfileHeader.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/2.
//

import SwiftUI

struct ProfileHeader<Content: View>: View {

	let avatarUrlString: String

	var content: Content?

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

			AsyncImage(url: URL(string: avatarUrlString)) { image in
				image
					.resizable()
					.scaledToFill()
			} placeholder: {
				Image(systemName: "person.fill")
					.resizable()
			}
			.frame(width: 80, height: 80)
			.clipShape(Circle())
			.offset(y: -40)
			.overlay(alignment: .center) {
				Text("Jason")
					.bodyBoldStyle()
					.offset(y: 25)
			}
		}
		.frame(height: 150)
    }
}

extension ProfileHeader {
	// Custom initializer
	init(avatarUrlString: String, @ViewBuilder content: () -> Content) {
		self.avatarUrlString = avatarUrlString
		self.content = content()
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
	ProfileHeader(avatarUrlString: "https://picsum.photos/200") {
		ActivityItemDisplay(title: "foodprints", count: 8)
		ActivityItemDisplay(title: "badges", count: 8)
		ActivityItemDisplay(title: "friends", count: 8)
	}
}
