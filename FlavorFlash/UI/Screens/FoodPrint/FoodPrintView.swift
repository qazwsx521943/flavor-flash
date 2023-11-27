//
//  FoodPrintView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/25.
//

import SwiftUI

struct FoodPrintView: View {
	@StateObject private var foodPrintViewModel = FoodPrintViewModel(dataService: FoodPrintDataService(path: "foodprints"))

	@State private var showCommentModal = false

	var body: some View {
		GeometryReader { geometry in
			ScrollView(.vertical, showsIndicators: false) {
				ForEach(foodPrintViewModel.posts) { post in
					FoodPrintCell(foodPrint: post) { id in
						showCommentModal = true
					}
					.frame(width: geometry.size.width, height: geometry.size.height / 1.5)
				}
			}
			.sheet(isPresented: $showCommentModal) {
				Text("this is comment view")
			}
		}
	}
}

#Preview {
	FoodPrintView()
}
