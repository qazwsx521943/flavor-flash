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
	let restaurant: Restaurant
	var addToFavorite: ((Restaurant) -> Void)?

    var body: some View {
		VStack {
			HStack {
				if let featureImage {
					Image(uiImage: featureImage)
						.resizable()
						.frame(width: 100, height: 100)
				}
				VStack {
					Text(restaurant.displayName.text)
						.font(.title3)
					Text(restaurant.formattedAddress!)
						.font(.subheadline)
				}
			}

			Image(systemName: "heart")
				.resizable()
				.frame(width: 30, height: 30)
				.tint(Color.red)
				.onTapGesture {
					print("added")
					addToFavorite?(restaurant)
				}
		}
		.task {
			PlaceImageFetcher.shared.fetchImage(for: restaurant.id) { featureImage = $0 }
		}
    }
}

extension RestaurantDetail {

}

//#Preview {
//    RestaurantDetail()
//}
