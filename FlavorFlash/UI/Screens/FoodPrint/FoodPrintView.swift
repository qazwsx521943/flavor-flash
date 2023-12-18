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

	@State private var isSelectedFoodPrint: FBFoodPrint?

	@State private var selectionType: SelectionType?

	@EnvironmentObject var navigationModel: NavigationModel

	enum SelectionType: String {
		case comment
		case report
		case send
	}

	var body: some View {
		NavigationStack {
			ScrollView(.vertical, showsIndicators: false) {

				VStack(alignment: .center, spacing: 30) {
					ForEach(foodPrintViewModel.posts) { post in
						FoodPrintCell(
							foodPrint: post,
							showComment: { foodprint in
								selectionType = .comment
								isSelectedFoodPrint = foodprint
							}, showReport: { foodprint in
								selectionType = .report
								isSelectedFoodPrint = foodprint
							}, likePost: {foodPrintViewModel.likePost(foodPrint: post)}, dislikePost: {
								foodPrintViewModel.dislikePost(foodPrint: post)
							})
						.padding(.horizontal, 8)
					}
				}
				//				.frame(maxWidth: .infinity, maxHeight: .infinity)
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
							.foregroundStyle(navigationModel.preferDarkMode ? .lightGreen : .darkGreen)
					}
				}
			}
			.navigationTitle("FoodPrints")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

extension FoodPrintView {
	private func sheetType(foodPrint: FBFoodPrint) -> some View {
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
		.environmentObject(NavigationModel())
}
