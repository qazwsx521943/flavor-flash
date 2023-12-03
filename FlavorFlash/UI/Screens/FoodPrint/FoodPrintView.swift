//
//  FoodPrintView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/25.
//

import SwiftUI

struct FoodPrintView: View {
	@StateObject private var foodPrintViewModel = FoodPrintViewModel(dataService: FoodPrintDataService(path: "foodprints"))
//	@StateObject private var foodPrintViewModel = FoodPrintViewModel(mockService: FoodPrintDataService(path: "foodprints"))
	@State private var showCommentModal = false

	var body: some View {
		NavigationStack {
			GeometryReader { geometry in
				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .center, spacing: 30) {
						ForEach(foodPrintViewModel.posts) { post in
							FoodPrintCell(foodPrint: post) { id in
								showCommentModal = true
							}
							.frame(width: geometry.size.width, height: geometry.size.height * 0.9)
							.padding(16)
							.background(Color.black)
						}
					}
					.frame(width: geometry.size.width)
				}
				.sheet(isPresented: $showCommentModal) {
					Text("this is comment view")
				}
				.toolbar {
					ToolbarItem(placement: .topBarTrailing) {
						NavigationLink {
							ChatListView()
						} label: {
							Image(systemName: "message.fill")
								.foregroundStyle(.white)
						}
					}
				}
				.navigationTitle("FoodPrints")
				.navigationBarTitleDisplayMode(.inline)
			}
		}
	}
}

#Preview {
	FoodPrintView()
}
