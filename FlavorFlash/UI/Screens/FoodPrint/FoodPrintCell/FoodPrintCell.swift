//
//  Post.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/27.
//

import SwiftUI

struct FoodPrintCell: View {
	static let mockFoodPrint = FoodPrint(
		id: "1",
		userId: "1",
		frontCameraImageUrl:
			// swiftlint:disable:next line_length
		"https://firebasestorage.googleapis.com:443/v0/b/flavorflash-4a1fc.appspot.com/o/user%2FQzZRdN8ggVeMjryKjPMUjcljRJQ2%2F72E63EBF-3530-47A7-8581-052C371E1663.jpeg?alt=media&token=c387ea4a-46bf-48a5-99d1-b9308dfe9f92",
		frontCameraImagePath: "user/QzZRdN8ggVeMjryKjPMUjcljRJQ2/72E63EBF-3530-47A7-8581-052C371E1663.jpeg",
		backCameraImageUrl:
			// swiftlint:disable:next line_length
		"https://firebasestorage.googleapis.com:443/v0/b/flavorflash-4a1fc.appspot.com/o/user%2FQzZRdN8ggVeMjryKjPMUjcljRJQ2%2F72E63EBF-3530-47A7-8581-052C371E1663.jpeg?alt=media&token=c387ea4a-46bf-48a5-99d1-b9308dfe9f92",
		backCameraImagePath: "user/QzZRdN8ggVeMjryKjPMUjcljRJQ2/5ECB61CA-F485-47A1-8C06-9B6C7BA7FFF9.jpeg",
		description: "好難吃",
		createdDate: Date.now)

	let foodPrint: FoodPrint

	var showComment: ((String) -> Void)?

	var body: some View {
		GeometryReader { geometry in
			let size = geometry.size
			VStack(alignment: .leading, spacing: 10) {
				HStack {
					Text("userId: \(foodPrint.userId)")
					Spacer()
				}
				.padding(.horizontal, 24)

				ScrollView(.horizontal, showsIndicators: false) {

					HStack {
						ForEach([foodPrint.backCameraImageUrl, foodPrint.frontCameraImageUrl], id: \.self) { imageUrl in
							AsyncImage(url: URL(string: imageUrl)!) { image in
								image
									.resizable()
									.scaledToFill()
									.frame(width: size.width, height: 200)
							} placeholder: {
								Image(systemName: "person.fill")
									.resizable()
									.scaledToFill()
									.frame(width: size.width, height: 300)
							}
						}
					}
				}
				.frame(width: size.width, height: 300)
				.onAppear {
					UIScrollView.appearance().isPagingEnabled = true
				}
				Group {
					HStack(spacing: 20) {
						Image(systemName: "paperplane.fill")
						Image(systemName: "ellipsis.message")
							.onTapGesture {
								showComment?(foodPrint.id)
							}

						Spacer()
					}
					.padding(.vertical, 16)

					postBody
				}
				.padding(.horizontal, 24)

				Spacer()
			}
		}
	}
}

private extension FoodPrintCell {

	var postBody: some View {
		Text(foodPrint.description)
			.lineLimit(...5)
			.frame(alignment: .leading)
	}
}

#Preview {
	FoodPrintCell(foodPrint: FoodPrintCell.mockFoodPrint)
}
