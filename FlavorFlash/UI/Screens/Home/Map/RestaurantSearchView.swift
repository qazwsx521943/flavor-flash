//
//  HomeMapView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI

struct RestaurantSearchView: View {
    @EnvironmentObject private var navigationModel: NavigationModel
    @StateObject private var restaurantDataModel = RestaurantViewModel()

    var body: some View {
        VStack { 
            HomeMapView(restaurants: $restaurantDataModel.restaurant)
        }
        .navigationTitle("MAP")
    }
}

#Preview {
    RestaurantSearchView()
        .environmentObject(NavigationModel())
}
