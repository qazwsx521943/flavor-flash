//
//  RestaurantDataModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation

final class RestaurantViewModel: ObservableObject {
    var category: String
    @Published var restaurants = [Restaurant]()

    init(searchCategory: String) {
        self.category = searchCategory
    }

    func setRestaurants(_ restaurants: [Restaurant]) {
        self.restaurants = restaurants
    }
}
