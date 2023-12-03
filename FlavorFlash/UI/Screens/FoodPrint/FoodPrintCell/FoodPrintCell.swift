//
//  Post.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/27.
//

import SwiftUI

struct FoodPrintCell: View {

	let foodPrint: FoodPrint

	@State private var isLiked: Bool = false

	var showComment: ((String) -> Void)?

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Text("userId: \(foodPrint.userId)")

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
						AsyncImage(url: URL(string: imageUrl)!) { image in
							image
								.resizable()
								.scaledToFill()
								.frame(width: size.width)
						} placeholder: {
							ProgressView()
								.frame(width: size.width)
						}
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
			.onAppear {
				UIScrollView.appearance().isPagingEnabled = true
			}
		}
	}

	private var actionsTab: some View {
		HStack(spacing: 20) {
			LikeButton(isLiked: $isLiked)
				.frame(width: 30, height: 30)

			Image(systemName: "paperplane.fill")
			Image(systemName: "ellipsis.message")
				.onTapGesture {
					showComment?(foodPrint.id)
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
	FoodPrintCell(foodPrint: FoodPrint.mockFoodPrint)
}
