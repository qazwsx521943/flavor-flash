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

		//		VStack {
		//			TagGrid(
		//				tags: restaurantCategoryViewModel.allCategories,
		//				selectedCategories: $restaurantCategoryViewModel.selectedCategories
		//			) { category in
		//				restaurantCategoryViewModel.addCategory(category)
		//			}
		//
		//			HStack {
		//				ForEach(restaurantCategoryViewModel.selectedCategories, id: \.self) { category in
		//					Text(category.rawValue)
		//						.foregroundStyle(.white)
		//				}
		//			}
		//
		NavigationStack {
			List {
				ForEach($restaurantCategoryViewModel.selectedCategories, editActions: .all) { category in
					Text(category.id)
				}
			}
			.refreshable {
				do {
					try await restaurantCategoryViewModel.load()
				} catch {
					debugPrint("sleep failed")
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
			.submitPressableStyle()
		}

	}
}

#Preview {
	RestaurantCategoryView()
}
