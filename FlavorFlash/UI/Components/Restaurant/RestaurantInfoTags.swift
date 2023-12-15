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
				Text(restaurant.roundedRating.description)
					.tagPaddingStyle(backgroundColor: ratingColor)

				Text("\(restaurant.userRatingCount ?? 0)")
					.prefixedWithSFSymbol(named: "bubble.fill", height: 14)
					.tagPaddingStyle(backgroundColor: ratingCountColor)

				Text(restaurant.status)
					.tagPaddingStyle(
						backgroundColor: restaurant.opening ? .green : .red)
			}
			.captionStyle()
			.foregroundStyle(.white)
		}
    }
}

// MARK: - Info tag color display Logic
extension RestaurantInfoTags {
	private var ratingColor: Color {
		let rating = restaurant.roundedRating
		switch rating {
		case _ where rating >= 4.0: return .green
		case _ where rating < 4 && rating > 3: return .orange
		case _ where rating < 3: return .red
		default: return .red
		}
	}

	private var ratingCountColor: Color {
		guard let ratingCount = restaurant.userRatingCount else { return .gray }
		switch ratingCount {
		case _ where ratingCount >= 300: return .green
		case _ where ratingCount < 300 && ratingCount > 100: return .orange
		case _ where ratingCount < 50: return .red
		default: return .red
		}
	}
}

#Preview {
	RestaurantInfoTags(restaurant: Restaurant.mockData)
}
