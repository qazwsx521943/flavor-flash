//
//  FlavorFlashCommentView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import SwiftUI
import ActivityIndicatorView

struct FlavorFlashCommentView: View {
	@ObservedObject var cameraDataModel: CameraDataModel

	@EnvironmentObject var navigationModel: NavigationModel

	@State private var showList = false

	@State private var showLoading = false

	var body: some View {
		GeometryReader { geometry in
			let size = geometry.size.width / 5
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

						VStack(alignment: .leading, spacing: 8) {
							HStack {
								Text(cameraDataModel.foodAnalyzeResult)
									.padding(8)
									.background(.purple.opacity(0.5))
									.clipShape(RoundedRectangle(cornerRadius: 10.0))

								Image(systemName: "pencil")
									.resizable()
									.foregroundStyle(.white)
									.frame(width: 20, height: 20)
							}

							Text(cameraDataModel.selectedRestaurant?.displayName.text ?? "選擇餐廳")
								.foregroundStyle(.white)
								.onTapGesture {
									showList = true
								}
								.sheet(isPresented: $showList) {
									VStack(alignment: .leading) {
										SearchBar(text: $cameraDataModel.searchText) { searchText in
											guard !searchText.isEmpty else {
												return
											}

											cameraDataModel.searchRestaurants()
										}

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
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(4)
					}
				}
				ScrollView {
					TextField("Leave a comment ...", text: $cameraDataModel.description, axis: .vertical)
						.lineLimit(5...9)
						.textFieldStyle(.roundedBorder)
						.background(.gray.opacity(0.7))
				}
				.scrollDismissesKeyboard(.interactively)

				Spacer()

				Button {
					self.hideKeyboard()
					showLoading = true
					Task {
						try await cameraDataModel.saveImages()
						showLoading = false
						navigationModel.selectedTab = .home
					}
				} label: {
					Text("Save FoodPrint ！")
						.font(.title3)
						.foregroundStyle(Color.black)
						.padding()
				}
				.background(Color.white)
				.clipShape(RoundedRectangle(cornerRadius: 20))
			}
			.overlay(alignment: .center) {
				ActivityIndicatorView(isVisible: $showLoading, type: .arcs())
					.frame(width: size, height: size)
					.foregroundStyle(.purple)
			}
			.onAppear {
				cameraDataModel.getCurrentLocation()
			}
			.padding(16)
		}
	}
}

#Preview {
	FlavorFlashCommentView(cameraDataModel: CameraDataModel())
}
