//
//  HomeMapView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI

struct RestaurantSearchView: View {
	@EnvironmentObject var homeViewModel: HomeViewModel

	@EnvironmentObject var navigationModel: NavigationModel

	@State private var showDetail: Bool = false

	var body: some View {

		RestaurantMapView()
			.overlay(alignment: .bottom) {
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(homeViewModel.restaurants) { restaurant in
							RestaurantCard(restaurant: restaurant)
								.frame(width: 250, height: 120)
								.onTapGesture {
									homeViewModel.selectedRestaurant = restaurant
									showDetail = true
								}
								.sheet(isPresented: $showDetail) {
									if let selected = homeViewModel.selectedRestaurant {
										RestaurantDetail(restaurant: selected) { restaurant in
											try? homeViewModel.saveFavoriteRestaurant(restaurant)
										}
										.padding()
										.presentationDetents([.medium])
									}
								}
						}
					}
				}
				.frame(height: 120)
			}
			.onAppear {
				navigationModel.hideTabBar()
			}
			.onDisappear {
				navigationModel.showTabBar()
			}
			.toolbar {
				NavigationBarBackButton()
			}
			.navigationBarBackButtonHidden()
			.navigationTitle(homeViewModel.category!.title)
			.navigationBarTitleDisplayMode(.inline)
	}
}

//#Preview {
//	RestaurantSearchView()
//}
