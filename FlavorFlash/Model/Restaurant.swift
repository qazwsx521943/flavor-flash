//
//  Restaurant.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import Foundation
import SwiftUI

struct Restaurant: Hashable, Codable {
    let title: String
    let description: String
    let images: [String]

    var featureImage: Image? {
        Image("home-icon")
    }
}
