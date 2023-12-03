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

			HStack(spacing: 80) {
				content
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
					.font(.title2)
					.bold()
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
				.font(.system(size: 12))
				.foregroundStyle(Color(uiColor: UIColor.lightGray))

			Text("\(count)")
				.font(.title2)
				.bold()
				.onTapGesture {
					action?()
				}
		}
	}
}

#Preview {
	ProfileHeader(avatarUrlString: "https://picsum.photos/200") {
		ActivityItemDisplay(title: "日記", count: 8)
		ActivityItemDisplay(title: "成就", count: 8)
		ActivityItemDisplay(title: "朋友", count: 8)
	}
}
