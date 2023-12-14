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

	let foodPrint: FoodPrint

	let author: FBUser?

	@State private var isLiked: Bool

	var showComment: ((FoodPrint) -> Void)?

	var showReport: ((FoodPrint) -> Void)?

	var likePost: () -> Void

	var dislikePost: () -> Void

	init(foodPrint: FoodPrint, author: FBUser?, showComment: ( (FoodPrint) -> Void)? = nil, showReport: ( (FoodPrint) -> Void)? = nil, likePost: @escaping () -> Void, dislikePost: @escaping () -> Void) {
		self.foodPrint = foodPrint
		self.author = author
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
			HStack {
				if let author {
					Text(author.displayName)
						.padding(.leading, 12)
						.bodyStyle()
				}

				Spacer()
			}

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

//						AsyncImage(url: URL(string: imageUrl)!) { image in
//							image
//								.resizable()
//								.rotationEffect(.degrees(90))
//								.scaledToFill()
//								.frame(width: size.width)
//						} placeholder: {
//							ProgressView()
//								.frame(width: size.width, height: 300)
//						}
					}
				}
			}
			.frame(width: size.width)
			.overlay(alignment: .bottomTrailing, content: {
				Text(foodPrint.category ?? "無")
					.foregroundStyle(
						LinearGradient(gradient: Gradient(colors: [Color.red, Color.purple]), startPoint: .leading, endPoint: .trailing)
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
			LikeButton(isLiked: $isLiked) {
				isLiked ? dislikePost() : likePost()
			}
			.frame(width: 30, height: 30)

			Image(systemName: "paperplane.fill")
			Image(systemName: "ellipsis.message")
				.onTapGesture {
					showComment?(foodPrint)
				}

			Spacer()
		}
	}

	private var postBody: some View {
		Text(foodPrint.description)
			.lineLimit(...5)
			.frame(alignment: .leading)
	}
}

#Preview {
	FoodPrintCell(foodPrint: FoodPrint.mockFoodPrint, author: nil) {
		print("cool")
	} dislikePost: {
		print("dislike")
	}
}
