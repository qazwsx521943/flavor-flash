//
//  RestaurantCard.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI

struct RestaurantCard: View {
    var restaurant: Restaurant

	@State private var image: UIImage?

    var body: some View {
        HStack {
			if let image {
				ZStack {
					Image(uiImage: image)
						.resizable()
						.scaledToFill()
						.frame(width: 60, height: 60)
						.cornerRadius(10)
				}
				.padding(5)
				.background(.yellow)
				.cornerRadius(10)
			}

            TextOverlay(title: restaurant.displayName.text, description: restaurant.formattedAddress ?? "無相關資訊")
        }
		.task {
			PlaceImageFetcher.shared.fetchImage(for: restaurant.id) { image = $0 }
		}
        .padding(5)
        .frame(width: 200, height: 100)
        .background(.black.opacity(0.5))
        .cornerRadius(15)
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

//#Preview {
//    RestaurantCard()
//}
