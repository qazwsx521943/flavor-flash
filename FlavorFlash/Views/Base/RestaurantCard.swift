//
//  RestaurantCard.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI

struct RestaurantCard: View {
    var restaurant: Restaurant = Restaurant(
        title: "季然食事",
        description: "好吃",
        images: ["1","2"]
    )

    var body: some View {
        HStack {
            if let image = restaurant.featureImage {
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                        TextOverlay(title: restaurant.title, description: restaurant.description)
            }
        }
        .frame(width: 200, height: 100)
    }
}

struct TextOverlay: View {
    var title: String
    var description: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack {
                Text(title)
                    .font(.title3)
                Text(description)
                    .font(.subheadline)
            }
            .frame(alignment: .leading)
        }
    }
}

#Preview {
    RestaurantCard()
}
