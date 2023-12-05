//
//  FlavorFlashCommentView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import SwiftUI

struct CommentView: View {
	@ObservedObject var cameraDataModel: CameraDataModel

	@EnvironmentObject var navigationModel: NavigationModel

	@State private var showList = false

	@State private var showLoading = false

	var body: some View {
		GeometryReader { geometry in
			ScrollView(.vertical, showsIndicators: false) {
				VStack {
					let size = geometry.size.width / 5
					if
						let primary = cameraDataModel.backCamImage,
						let secondary = cameraDataModel.frontCamImage
					{
						ZStack(alignment: .topLeading) {
							PrimaryPreviewView(previewImage: primary)
								.border(Color.white, width: 2)
								.overlay(alignment: .bottomLeading) {
									Text(cameraDataModel.foodAnalyzeResult)
										.font(.caption)
										.bold()
										.padding(4)
										.background(.black.opacity(0.5))
										.clipShape(RoundedRectangle(cornerRadius: 10.0))
										.offset(x: 5, y: -5)
								}

							SecondaryPreviewView(previewImage: secondary)
						}
					}

					VStack(alignment: .leading, spacing: 8) {
						Text(cameraDataModel.selectedRestaurant?.displayName.text ?? "選擇餐廳")
							.foregroundStyle(.white)
							.onTapGesture {
								showList = true
							}
							.sheet(isPresented: $showList) {
								searchNearByRestaurantSheet
							}
					}
					.frame(maxWidth: .infinity, alignment: .leading)

					TextEditor(text: $cameraDataModel.description)
						.foregroundColor(Color.secondary)
						.font(.custom("HelveticaNeue", size: 16))
						.lineLimit(2...5)
						.lineSpacing(5)
						.frame(height: 200)
						.padding(8)

					saveFoodPrintButton
				}
				.padding(.horizontal, 16)
				.onAppear {
					cameraDataModel.getCurrentLocation()
				}
			}
			.scrollDismissesKeyboard(.interactively)
		}
	}
}

extension CommentView {
	// MARK: - Layout
	private var searchNearByRestaurantSheet: some View {
		VStack(alignment: .leading) {
			SearchBar(text: $cameraDataModel.searchText) { searchText in
				guard !searchText.isEmpty else {
					return
				}

				cameraDataModel.searchRestaurants()
			}

			Spacer()

			if showList {
				ScrollView(.vertical, showsIndicators: false) {
					ForEach(cameraDataModel.nearByRestaurants) { restaurant in
						VStack(alignment: .leading, spacing: 5) {
							Text(restaurant.displayName.text)
								.font(.title2)
								.foregroundStyle(Color.white)
							Text(restaurant.shortFormattedAddress ?? "尚無資訊")
								.font(.caption)
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.init(top: 0, leading: 16, bottom: 16, trailing: 16))
						.onTapGesture {
							cameraDataModel.selectedRestaurant = restaurant
							showList = false
						}
					}
				}
				.scrollDismissesKeyboard(.interactively)
			}
		}
		.onAppear {
			cameraDataModel.fetchNearByRestaurants()
		}
	}

	private var saveFoodPrintButton: some View {
		Button {
			self.hideKeyboard()
			showLoading = true
			Task {
				try await cameraDataModel.saveImages()
				showLoading = false
				navigationModel.selectedTab = .home
			}
		} label: {
			Text("送出 ")
				.suffixWithSFSymbol(named: "paperplane.fill", height: 25, tintColor: .black)
				.font(.title3)
				.foregroundStyle(Color.black)
				.padding()
		}
		.background(Color.white)
		.clipShape(RoundedRectangle(cornerRadius: 10))
	}
}

#Preview {
	CommentView(cameraDataModel: CameraDataModel())
}
