//
//  RestaurantCollection.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/8.
//

import SwiftUI

struct RestaurantCollection: View {

	@Binding var restaurants: [Restaurant]

	var addAction: ((Restaurant) -> Void)?

	var deleteAction: ((Restaurant) -> Void)?

    var body: some View {
		ScrollView {
			VStack {

				Text("To-Eat List")
					.bodyBoldStyle()

				ForEach(Array(restaurants.enumerated()), id: \.element.id) { index, restaurant in
					ZStack {
						Color(.shadowGray)
							.roundedRectRadius(20)

						Color(.darkOrange)
							.roundedRectRadius(20)
							.padding(.horizontal, 65)

						HStack {
							Spacer()

							Button {
								restaurants.remove(at: index)
								deleteAction?(restaurant)
							} label: {
								Image(systemName: "hand.thumbsdown")
									.foregroundStyle(.white)
									.fontWeight(.heavy)
									.frame(width: 65, height: 65)
							}

							Button {
								restaurants.remove(at: index)
								addAction?(restaurant)
							} label: {
								Image(systemName: "heart")
									.foregroundStyle(.white)
									.fontWeight(.heavy)
									.frame(width: 65, height: 65)
							}
						}

						RestaurantCollectionItem(restaurant: restaurants[index])
							.roundedRectRadius(20)
							.offset(x: restaurants[index].offset)
							.gesture(DragGesture().onChanged { value in
								onChanged(value: value, index: index)
							}.onEnded { value in
								onEnded(value: value, index: index)
							})
					}
					.padding(.horizontal)
					.padding(.top)
				}
			}
		}
    }
}

// MARK: - closures
extension RestaurantCollection {
	private func onChanged(value: DragGesture.Value, index: Int) {
		if value.translation.width < 0 {
			restaurants[index].offset = value.translation.width
		}
	}

	private func onEnded(value: DragGesture.Value, index: Int) {
		withAnimation {
			if -value.translation.width >= 100 {
				restaurants[index].offset = -130
			} else {
				restaurants[index].offset = 0
			}
		}
	}
}

// MARK: - Custom initializer
extension RestaurantCollection {
	init(
		restaurants: Binding<[Restaurant]>) {
			self._restaurants = restaurants
		}
}

#Preview {
	Group {
//		RestaurantCollection(restaurants: .constant(Array(repeating: Restaurant.mockData, count: 5)))

	RestaurantCollection(restaurants: .constant(Array(repeating: Restaurant.mockData, count: 5)))
	}
}
