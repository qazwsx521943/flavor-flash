//
//  RestaurantDetailView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/20.
//

import SwiftUI
import GooglePlaces

struct RestaurantDetail: View {
	@State private var featureImage: UIImage?

	@State private var isLiked = false

	let restaurant: Restaurant

	var addToFavorite: ((Restaurant) -> Void)?

    var body: some View {
		VStack(alignment: .leading, spacing: 10) {
//			HStack {
//				if let featureImage {
//					Image(uiImage: featureImage)
//						.resizable()
//						.frame(width: 100, height: 100)
//				}
//			}
			HStack {
				VStack(alignment: .leading, spacing: 5) {
					Text(restaurant.displayName.text)
						.bodyBoldStyle()

					RestaurantInfoTags(restaurant: restaurant)

					Text(restaurant.formattedAddress ?? "unknown")
						.detailBoldStyle()
				}

				Spacer()

				BookmarkButton(isLiked: $isLiked) {
					addToFavorite?(restaurant)
				}
			}

			Divider()

			if let openingDays = restaurant.regularOpeningHours?.weekdayDescriptions {
				VStack(alignment: .leading, spacing: 4) {
					Text("Opening hours:")
						.captionStyle()

					ForEach(openingDays, id: \.self) { weekDay in
						Text(weekDay)
							.detailBoldStyle()
					}
				}
			}

			Spacer()

		}
		.task {
			PlaceFetcher.shared.fetchImage(for: restaurant.id) { featureImage = $0 }
		}
    }
}

extension RestaurantDetail {

}

#Preview {
	RestaurantDetail(restaurant: Restaurant.mockData)
}
