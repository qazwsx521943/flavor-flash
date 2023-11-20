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
