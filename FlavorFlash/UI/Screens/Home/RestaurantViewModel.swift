//
//  RestaurantDataModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation

final class RestaurantViewModel: ObservableObject {
    var restaurant: [Restaurant]

    init() {
        self.restaurant = [
            Restaurant(title: "季然食事", description: "好吃", images: [], latitude: 25.040141, longitude: 121.532135),
            Restaurant(title: "八方雲集", description: "下水餃", images: [], latitude: 25.038833, longitude: 121.532529)
        ]
    }
}
