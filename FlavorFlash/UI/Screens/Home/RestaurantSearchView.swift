//
//  HomeMapView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI

struct RestaurantSearchView: View {
    @StateObject private var restaurantViewModel: RestaurantViewModel
    @State private var showDetail: Bool = false

    var body: some View {
        VStack {
            RestaurantMapView(restaurantViewModel: restaurantViewModel)
            .overlay(alignment: .bottom) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(restaurantViewModel.restaurants) { restaurant in
                            RestaurantCard(restaurant: restaurant)
                                .onTapGesture {
                                    restaurantViewModel.selectedRestaurant = restaurant
                                    showDetail = true
                                }
                                .sheet(isPresented: $showDetail) {
                                    if let selected = restaurantViewModel.selectedRestaurant {
										RestaurantDetail(restaurant: selected) { restaurant in
											try? restaurantViewModel.saveFavoriteRestaurant(restaurant)
										}
                                    }
                                }
                        }
                    }
                }
                .frame(height: 100)
            }
        }
		.navigationTitle($restaurantViewModel.category)
    }

    init(category: String) {
        _restaurantViewModel = StateObject(wrappedValue: RestaurantViewModel(searchCategory: category))
    }
}

#Preview {
    RestaurantSearchView(category: "lunch")
}
