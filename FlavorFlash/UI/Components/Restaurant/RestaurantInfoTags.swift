//
//  RestaurantInfoTags.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/8.
//

import SwiftUI

struct RestaurantInfoTags: View {

	let restaurant: Restaurant

    var body: some View {
		HStack {
			Group {
				Text(restaurant.roundedRating)
					.tagPaddingStyle()

				Text("\(restaurant.userRatingCount ?? 0)")
					.prefixedWithSFSymbol(named: "bubble.fill", height: 14)
					.tagPaddingStyle(backgroundColor: .accent)

				Text(restaurant.status)
					.tagPaddingStyle(
						backgroundColor: restaurant.opening ? .green : .red)
			}
			.captionStyle()
		}
    }
}

#Preview {
	RestaurantInfoTags(restaurant: Restaurant.mockData)
}
