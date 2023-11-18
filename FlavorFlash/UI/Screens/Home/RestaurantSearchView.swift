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

    var body: some View {
        VStack { 
            RestaurantMapView(restaurants: $restaurantDataModel.restaurants)
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
