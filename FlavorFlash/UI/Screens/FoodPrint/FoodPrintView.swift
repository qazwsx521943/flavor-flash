//
//  FoodPrintView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/25.
//

import SwiftUI

struct FoodPrintView: View {
	@StateObject private var foodPrintViewModel = FoodPrintViewModel(dataService: FoodPrintDataService(path: "foodprints"))

    var body: some View {
		List {
			ForEach(foodPrintViewModel.posts) { post in
				Text(post.userId)
			}
		}
    }
}

#Preview {
    FoodPrintView()
}
