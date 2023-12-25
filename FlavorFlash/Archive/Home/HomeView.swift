//
//  HomeView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI
import os.log

// This feature will be deprecated and hidden because i have no quotas of google place api
struct HomeView: View {
	@StateObject private var viewModel = HomeViewModel()

	@State private var animate = false

	@State private var showRestaurantCollection: Bool = false

	@State private var showMapSliders: Bool = false

	var body: some View {
		NavigationStack {
			let animation = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
			ZStack {
				VStack {

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
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.overlay(alignment: .topTrailing) {
				VStack {

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
			.onAppear {
				try? viewModel.checkUpdate()
			}
			.navigationTitle("NumNum")
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
