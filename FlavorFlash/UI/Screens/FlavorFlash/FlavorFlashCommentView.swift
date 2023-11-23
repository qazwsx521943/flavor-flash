//
//  FlavorFlashCommentView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import SwiftUI

struct FlavorFlashCommentView: View {
	@ObservedObject var cameraDataModel: CameraDataModel
	@State private var showList = false

	var body: some View {
		VStack {
			if
				let primary = cameraDataModel.backCamImage,
				let secondary = cameraDataModel.frontCamImage
			{
				HStack {
					ZStack {
						PrimaryPreviewView(previewImage: primary)
							.frame(width: 200, height: 200)
							.clipped()
							.overlay(alignment: .topLeading) {
								SecondaryPreviewView(previewImage: secondary, width: 80, height: 100)
							}
					}

					Spacer()

					VStack {
						Text(cameraDataModel.foodAnalyzeResult)

//						TextField(text: $cameraDataModel.category) {
//							Text("分類")
//						}

						Text("餐廳")
							.foregroundStyle(.white)
							.onTapGesture {
								showList = true
							}
							.sheet(isPresented: $showList) {
								VStack {
									SearchBar(text: $cameraDataModel.searchText) { searchText in
										guard !searchText.isEmpty else {
											return
										}

										cameraDataModel.searchRestaurants()
									}

									if showList {
										Group {
											ForEach(cameraDataModel.nearByRestaurants) { restaurant in
												VStack {
													Text(restaurant.displayName.text)
														.font(.title2)
														.foregroundStyle(Color.white)
													Text(restaurant.shortFormattedAddress ?? "尚無資訊")
														.font(.caption)
												}
												.onTapGesture {
													cameraDataModel.selectedRestaurant = restaurant
													showList = false
												}
											}
										}
									}
								}
								.onAppear {
									cameraDataModel.fetchNearByRestaurants()
								}
								if let selectedRestaurant = cameraDataModel.selectedRestaurant {

									Text(selectedRestaurant.displayName.text)
										.foregroundStyle(Color.white)
								}
							}

					}
				}
			}

			TextField("Comment:", text: $cameraDataModel.comment)




			Button {
				Task {
					try await cameraDataModel.saveImages()
				}
			} label: {
				Text("Save!")
					.font(.title3)
					.foregroundStyle(.purple)
			}
		}
		.onAppear {
			cameraDataModel.getCurrentLocation()
		}
		.padding(16)
	}
}

#Preview {
	FlavorFlashCommentView(cameraDataModel: CameraDataModel())
}
