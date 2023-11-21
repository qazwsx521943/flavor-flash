//
//  TagGrid.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import SwiftUI

struct TagGrid: View {
	let columns = [GridItem(.adaptive(minimum: 100))]

	let tags: [RestaurantCategory]
	@Binding var selectedCategories: [RestaurantCategory]
	var selectCategory: ((RestaurantCategory) -> Void)?

	var body: some View {
		ScrollView(.vertical, showsIndicators: false) {
			LazyVGrid(columns: columns) {
				ForEach(tags, id: \.id) { tag in
					HStack {
						Tag(item: tag) { 
							selectCategory?(tag)
						}
					}
				}
			}
		}
	}
}

#Preview {
	TagGrid(tags: RestaurantCategory.allCases, selectedCategories: .constant([.barbecue]))
}
