//
//  HomeMapView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI

struct RestaurantSearchView: View {
    @EnvironmentObject private var navigationModel: NavigationModel
    @StateObject private var restaurantDataModel: RestaurantViewModel
    @State private var showDetail: Bool = false

    var body: some View {
        VStack { 
            RestaurantMapView(
                restaurants: $restaurantDataModel.restaurants,
                currentLocation: $restaurantDataModel.currentLocation,
                category: $restaurantDataModel.category
            )
                .overlay(alignment: .bottom) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(restaurantDataModel.restaurants) { restaurant in
                                RestaurantCard(restaurant: restaurant)
                                    .onTapGesture {
                                        restaurantDataModel.selectedRestaurant = restaurant
                                        showDetail = true
                                    }
                                    .sheet(isPresented: $showDetail) {
                                        if let selected = restaurantDataModel.selectedRestaurant {
                                            VStack {
                                                Text(selected.displayName.text)
                                                    .font(.title)
                                                    .foregroundStyle(.blue)
                                                Text(selected.formattedAddress!)
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    .frame(height: 100)
                    
                }
        }
        .navigationTitle("MAP")
    }

    init(category: String) {
        _restaurantDataModel = StateObject(wrappedValue: RestaurantViewModel(searchCategory: category))
    }
}

#Preview {
    RestaurantSearchView(category: "lunch")
        .environmentObject(NavigationModel())
}
