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

	var hideActionTab: Bool

	init(
		foodPrint: FBFoodPrint,
		showComment: ( (FBFoodPrint) -> Void)? = nil,
		showReport: ( (FBFoodPrint) -> Void)? = nil,
		likePost: @escaping () -> Void,
		dislikePost: @escaping () -> Void,
		hideActionTab: Bool = false) {
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
		self.hideActionTab = hideActionTab
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {

			photoDisplay

			Group {
				if !hideActionTab {
					actionsTab
				}

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
		FoodPrintPhotoDisplay(
			front: foodPrint.frontCameraImageUrl,
			back: foodPrint.backCameraImageUrl
		)
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
			HStack {
				Text(foodPrint.username)
					.captionBoldStyle()

				if let restaurantName = foodPrint.restaurantName {
					Text("at \(restaurantName)")
						.captionStyle()
				}
			}

			Text(foodPrint.description)
				.captionStyle()
				.lineLimit(...5)
				.frame(alignment: .leading)
		}
	}
}

struct FoodPrintPhotoDisplay: View {

	let front: String

	let back: String

	@State private var isBackPrimary = true

	@State private var offset: CGSize = .zero

	@State private var lastOffset: CGSize = .zero

	var body: some View {
		ZStack(alignment: .topLeading) {
			KFImage(URL(string: back))
				.resizable()
				.aspectRatio(contentMode: .fill)
				.rotationEffect(.degrees(90))

			KFImage(URL(string: front))
				.resizable()
				.aspectRatio(contentMode: .fill)
				.rotationEffect(.degrees(90))
				.frame(width: 80, height: 100)
				.clipShape(RoundedRectangle(cornerRadius: 10))
				.border(.black, width: 2)
				.offset(offset)
				.gesture(
					DragGesture()
						.onChanged({ value in
							offset = CGSize(
								width: lastOffset.width + value.translation.width,
								height: lastOffset.height + value.translation.height
							)
						})
						.onEnded({ value in
							lastOffset = offset
						})
				)
		}
		.clipped()
	}
}

#Preview {
	FoodPrintCell(foodPrint: FBFoodPrint.mockFoodPrint) {

	} dislikePost: {

	}

}
