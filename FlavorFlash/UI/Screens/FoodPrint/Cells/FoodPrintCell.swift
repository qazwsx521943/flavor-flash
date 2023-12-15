//
//  Post.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/27.
//

import SwiftUI
import Kingfisher
import FirebaseAuth

struct FoodPrintCell: View {

	let foodPrint: FBFoodPrint

	@State private var isLiked: Bool

	var showComment: ((FBFoodPrint) -> Void)?

	var showReport: ((FBFoodPrint) -> Void)?

	var likePost: () -> Void

	var dislikePost: () -> Void

	init(
		foodPrint: FBFoodPrint,
		showComment: ( (FBFoodPrint) -> Void)? = nil,
		showReport: ( (FBFoodPrint) -> Void)? = nil,
		likePost: @escaping () -> Void,
		dislikePost: @escaping () -> Void) {
		self.foodPrint = foodPrint

		if
			let currentUserId = Auth.auth().currentUser?.uid,
			let isLiked = foodPrint.likedBy?.contains(where: { id in
				currentUserId == id
			}) {
			self._isLiked = State(wrappedValue: isLiked)
		} else {
			self._isLiked = State(wrappedValue: false)
		}
		self.showComment = showComment
		self.showReport = showReport
		self.likePost = likePost
		self.dislikePost = dislikePost
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {

			photoDisplay

			Group {
				actionsTab

				postBody

				Text(foodPrint.getRelativeTimeString)
					.font(.caption2)
					.foregroundStyle(Color(UIColor.systemGray))
			}
			.padding(.horizontal, 12)
			Spacer()
		}
	}
}

private extension FoodPrintCell {
	// MARK: - Layout
	private var photoDisplay: some View {
		GeometryReader { geometry in
			let size = geometry.size
			ScrollView(.horizontal, showsIndicators: false) {
				HStack {
					ForEach(foodPrint.getAllImagesURL, id: \.self) { imageUrl in
						KFImage(URL(string: imageUrl))
							.placeholder({
								ProgressView()
									.frame(width: size.width, height: 300)
							})
							.resizable()
							.rotationEffect(.degrees(90))
							.scaledToFill()
							.frame(width: size.width)

					}
				}
			}
			.frame(width: size.width)
			.overlay(alignment: .bottomTrailing, content: {
				Text(foodPrint.category ?? "unknown")
					.captionBoldStyle()
					.foregroundStyle(
						.lightGreen
					)
					.padding(.vertical, 4)
					.padding(.horizontal, 8)
					.background(
						RoundedRectangle(cornerRadius: 5)
							.fill(.black.opacity(0.7))
					)
			})
			.overlay(alignment: .topTrailing, content: {
				Text("...")
					.font(.title2)
					.bold()
					.padding(.trailing, 12)
					.onTapGesture {
						showReport?(foodPrint)
					}
			})
			.onAppear {
				UIScrollView.appearance().isPagingEnabled = true
			}
		}
	}

	private var actionsTab: some View {
		HStack(spacing: 20) {
			LikeButton(isLiked: $isLiked, frame: CGSize(width: 20, height: 20)) {
				isLiked ? dislikePost() : likePost()
			}

			Image(systemName: "paperplane.fill")

			Image(systemName: "ellipsis.message")
				.onTapGesture {
					showComment?(foodPrint)
				}

			Spacer()
		}
	}

	private var postBody: some View {
		VStack(alignment: .leading, spacing: 5) {
			Text(foodPrint.username)
				.captionBoldStyle()

			Text(foodPrint.description)
				.captionStyle()
				.lineLimit(...5)
				.frame(alignment: .leading)
		}
	}
}

#Preview {
	FoodPrintCell(foodPrint: FBFoodPrint.mockFoodPrint) {

	} dislikePost: {

	}

}
