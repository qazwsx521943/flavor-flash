//
//  HomeView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI
import os.log
enum BoxSkin: String {
	case cat01 = "cat_1"
	case cat02 = "cat_2"
	case cat03 = "cat_3"
}

struct HomeView: View {
	@StateObject private var viewModel = HomeViewModel()

	@State private var animate = false

	@State private var showPetSelection = false

	@AppStorage("selectedSkin") var selectedSkin: BoxSkin?

	@State private var showRestaurantCollection: Bool = false

	@State private var showMapSliders: Bool = false

	var body: some View {
		NavigationStack {
			let animation = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
			ZStack {
				VStack {
					if let selectedSkin {
						Image(selectedSkin.rawValue)
							.resizable()
							.frame(
								width: 150, height: 150
							)
							.overlay(alignment: .top) {
								Text(viewModel.category?.title ?? "What to eat？")
									.captionStyle()
									.foregroundStyle(.white)
									.padding(.vertical, 8)
									.padding(.horizontal, 12)
									.background(
										Capsule()
											.fill(.shadowGray)
											.zIndex(1.0)
											.overlay(alignment: .bottom) {
												Polygon(sides: 3)
													.fill(.shadowGray)
													.frame(width: 20, height: 20)
													.rotationEffect(.degrees(90.0))
													.offset(y: 5)
											}
									)
									.offset(y: -30)
							}
							.onTapGesture {
								viewModel.randomCategory()
								withAnimation(animation) {
									animate = true
								}
							}
					}

					if viewModel.category != nil {
						NavigationLink {
							RestaurantSearchView()
								.environmentObject(viewModel)
						} label: {
							Text("Search Nearby！")
								.bodyBoldStyle()
								.frame(height: 55)
								.frame(width: 200)
								.background(.black.opacity(0.7))
								.clipShape(RoundedRectangle(cornerRadius: 10.0))
								.shadow(color: Color.white.opacity(0.7), radius: animate ? 10 : 0)
						}
						.foregroundStyle(.white)
					}
				}

				GeometryReader { geo in
					PetSelectionView(currentSelectedSkin: $selectedSkin) { boxSkin in
						selectedSkin = boxSkin
					}
					.frame(width: geo.size.width * 0.6)
					.offset(x: showPetSelection ? geo.size.width * 0.4 : geo.size.width)
					.transition(.move(edge: .trailing))
					.animation(.easeIn, value: showPetSelection)
					.environmentObject(viewModel)
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.overlay(alignment: .topTrailing) {
				VStack {
					Button {
						withAnimation {
							showPetSelection.toggle()
						}
					} label: {
						Image(systemName: "pawprint.fill")
					}
					.buttonStyle(IconButtonStyle())

					Button {
						showRestaurantCollection.toggle()
					} label: {
						Image(systemName: "bookmark.fill")
					}
					.buttonStyle(IconButtonStyle())
				}
			}
			.overlay(alignment: .topLeading) {
				Button {
					showMapSliders.toggle()
				} label: {
					Image(systemName: "slider.horizontal.3")
				}
				.buttonStyle(IconButtonStyle())
			}
			.sheet(isPresented: $showRestaurantCollection) {
				RestaurantCollection(restaurants: $viewModel.userSavedRestaurants) { restaurant in
					try? viewModel.saveLovedRestaurant(restaurant)
				} deleteAction: { restaurant in
					try? viewModel.saveBlockedRestaurant(restaurant)
				}
				.padding(.top, 12)
			}
			.sheet(isPresented: $showMapSliders) {
				MapSelection(
					maxResultValue: $viewModel.maxResultCount.unwrapped(20),
					searchRadius: $viewModel.searchRadius.unwrapped(1000),
					rankPreference: $viewModel.rankPreference.unwrapped(.distance))
				.padding()
				.presentationDetents([.medium])
			}
			.navigationTitle("My App")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

extension HomeView {
}

#Preview {
	HomeView()
}

fileprivate let logger = Logger(subsystem: "flavor-flash.homepage", category: "Home")
