//
//  RestaurantCategoryView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/21.
//

import SwiftUI

struct RestaurantCategoryView: View {
	@StateObject private var restaurantCategoryViewModel = RestaurantCategoryViewModel()
	@EnvironmentObject private var navigationModel: NavigationModel
	@Environment(\.editMode) private var editMode

	@State private var category: String = ""
	var body: some View {

		NavigationStack {
			List {
				ForEach($restaurantCategoryViewModel.selectedCategories, editActions: .all) { category in
					Text(category.id)
				}
			}
			.navigationTitle("Select Categories")

			Text("\(restaurantCategoryViewModel.selectedCategories.count) selections")
			
			Button {
				Task {
					try? await restaurantCategoryViewModel.saveCategories()
					navigationModel.showCategorySelectionModal = false
				}
			} label: {
				Text("Continue")
			}
			.submitLoadingButtonStyle()
		}

	}
}

#Preview {
	RestaurantCategoryView()
}
