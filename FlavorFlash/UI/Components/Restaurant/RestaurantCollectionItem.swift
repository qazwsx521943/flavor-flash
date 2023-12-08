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
				.frame(width: 60, height: 60)

			VStack(alignment: .leading) {
				Text(restaurant.displayName.text)
					.captionBoldStyle()

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
