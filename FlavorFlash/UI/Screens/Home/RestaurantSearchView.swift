//
//  HomeMapView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI

struct RestaurantSearchView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State private var showDetail: Bool = false

    var body: some View {

        GeometryReader { geometry in
			VStack {
				RestaurantMapView()
				.overlay(alignment: .bottom) {
					ScrollView(.horizontal, showsIndicators: false) {
						HStack {
							ForEach(homeViewModel.restaurants) { restaurant in
								RestaurantCard(restaurant: restaurant)
									.frame(width: geometry.size.width * 0.75, height: 120)
									.onTapGesture {
										homeViewModel.selectedRestaurant = restaurant
										showDetail = true
									}
									.sheet(isPresented: $showDetail) {
										if let selected = homeViewModel.selectedRestaurant {
											RestaurantDetail(restaurant: selected) { restaurant in
												try? homeViewModel.saveFavoriteRestaurant(restaurant)
											}
										}
									}
							}
						}
					}
					.frame(height: 120)
				}
			}
			.navigationTitle(homeViewModel.category!.title)
			.navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RestaurantSearchView()
}
