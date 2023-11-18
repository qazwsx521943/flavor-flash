//
//  RestaurantDataModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation
import MapKit

final class RestaurantViewModel: ObservableObject {
    var category: String
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var restaurants = [Restaurant]()
    @Published var selectedRestaurant: Restaurant? {
        didSet {
            self.currentLocation = selectedRestaurant?.coordinate
        }
    }

    init(searchCategory: String) {
        self.category = searchCategory
    }

    func setRestaurants(_ restaurants: [Restaurant]) {
        self.restaurants = restaurants
    }
}
