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

	@Environment(\.dismiss) private var dismiss

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
										.captionBoldStyle()
										.foregroundStyle(.white)
										.padding(4)
										.background(.black.opacity(0.5))
										.clipShape(RoundedRectangle(cornerRadius: 10.0))
										.offset(x: 5, y: -5)
								}

							SecondaryPreviewView(previewImage: secondary)
						}
						.clipped()
					}

					VStack(alignment: .leading, spacing: 8) {
						Text(cameraDataModel.selectedRestaurant?.displayName.text ?? "Select Restaurant")
							.bodyStyle()
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
						.bodyStyle()
						.lineLimit(2...5)
						.lineSpacing(5)
						.frame(height: 200)

					saveFoodPrintButton
				}
				.padding(.horizontal, 16)
				.onAppear {
					cameraDataModel.getCurrentLocation()
				}
			}
			.scrollDismissesKeyboard(.interactively)
			.navigationBarBackButtonHidden()
			.toolbar {
				NavigationBarBackButton()
			}
			.overlay(alignment: .center) {
				if showLoading {
					Color.black.opacity(0.3)
						.ignoresSafeArea()
					NNLoadingIndicator()
						.frame(width: 300, height: 300)
				}
			}
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
								.captionBoldStyle()
							Text(restaurant.shortFormattedAddress ?? "unknown")
								.detailBoldStyle()
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
				try await cameraDataModel.saveFoodPrint()
				showLoading = false
				dismiss()
				navigationModel.selectedTab = .home
			}
		} label: {
			Text("Save FoodPrint!")
				.suffixWithSFSymbol(named: "paperplane.fill", height: 25, tintColor: .black)
		}
		.buttonStyle(LargePrimaryButtonStyle())
	}
}

#Preview {
	CommentView(cameraDataModel: CameraDataModel())
}
