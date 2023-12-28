//
//  RestaurantCollectionItem.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/8.
//

import SwiftUI

struct RestaurantCollectionItem: View {
	let restaurant: Restaurant

	@State private var image: UIImage?

    var body: some View {
		HStack(spacing: 20) {
			if let image {
				Image(uiImage: image)
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(width: 60, height: 60)
					.clipShape(RoundedRectangle(cornerRadius: 10.0))
			}

			VStack(alignment: .leading) {
				Text(restaurant.displayName.text)
					.captionBoldStyle()

				RestaurantInfoTags(restaurant: restaurant)
			}
			.foregroundStyle(.white)
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(
			.shadowGray
		)
		.task {
			PlaceFetcher.shared.fetchImage(for: restaurant.id) { image = $0 }
		}
    }
}

#Preview {
	RestaurantCollectionItem(restaurant: Restaurant.mockData)
}
