//
//  Restaurant.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation
import SwiftUI
import CoreLocation

struct Restaurant: Hashable, Codable {
    let title: String
    let description: String
    let images: [String]
    let latitude: CGFloat
    let longitude: CGFloat

    var featureImage: Image? {
        Image("home-icon")
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
