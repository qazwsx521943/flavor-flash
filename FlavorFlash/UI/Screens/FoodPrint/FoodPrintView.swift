//
//  FoodPrintView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/25.
//

import SwiftUI

struct FoodPrintView: View {
	@StateObject private var foodPrintViewModel = FoodPrintViewModel(dataService: FoodPrintDataService(path: "foodprints"))
//	@StateObject private var foodPrintViewModel = FoodPrintViewModel(
//mockService: FoodPrintDataService(path: "foodprints"))
	@State private var showCommentModal = false

	@State private var showReportModal = false

	@State private var isSelectedFoodPrint: FoodPrint?

	@State private var selectionType: SelectionType = .comment

	enum SelectionType: String {
		case comment
		case report
		case send
	}

	var body: some View {
		NavigationStack {
			GeometryReader { geometry in
				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .center, spacing: 30) {
						ForEach(foodPrintViewModel.posts) { post in
							FoodPrintCell(
								foodPrint: post,
								author: foodPrintViewModel.friends.first { $0.id == post.userId },
								showComment: { foodprint in
								isSelectedFoodPrint = foodprint
								selectionType = .comment
							}, showReport: { foodprint in
								isSelectedFoodPrint = foodprint
								selectionType = .report
							}, likePost: {foodPrintViewModel.likePost(foodPrint: post)}, dislikePost: {
								foodPrintViewModel.dislikePost(foodPrint: post)
							})
							.frame(width: geometry.size.width, height: geometry.size.height * 0.9)
							.padding(16)
							.background(Color.black)
						}
					}
					.frame(width: geometry.size.width)
					.sheet(item: $isSelectedFoodPrint) { item in
						sheetType(foodPrint: item)
					}
				}
				.refreshable {
					foodPrintViewModel.reloadData()
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

extension FoodPrintView {
	private func sheetType(foodPrint: FoodPrint) -> some View {
		ZStack {
			switch selectionType {
			case .comment:
				CommentSheetView(foodPrint: foodPrint) { comment in
					foodPrintViewModel.leaveComment(foodPrint: foodPrint, comment: comment)
				}
				.presentationDetents([.medium])
			case .report:
				ReportSheetView { reason in
					foodPrintViewModel.reportFoodPrint(id: foodPrint.id, reason: reason)
				}
				.presentationDetents([.medium])
			default:
				ReportSheetView()
					.presentationDetents([.medium])
			}
		}
	}
}

#Preview {
	FoodPrintView()
}
