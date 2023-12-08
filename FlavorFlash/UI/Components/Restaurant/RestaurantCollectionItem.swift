//
//  RestaurantCollectionItem.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/8.
//

import SwiftUI

struct RestaurantCollectionItem: View {
	let restaurant: Restaurant


    var body: some View {
		HStack {
			Image(systemName: "person.fill")
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: 80, height: 80)

			VStack {
				Text(restaurant.displayName.text)
					.bodyBoldStyle()

				RestaurantInfoTags(restaurant: restaurant)
			}
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(
			.shadowGray
		)
    }
}

#Preview {
	RestaurantCollectionItem(restaurant: Restaurant.mockData)
}
