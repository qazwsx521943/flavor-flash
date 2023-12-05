//
//  CommentSheetView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/4.
//

import SwiftUI

struct CommentSheetView: View {
	let foodPrint: FoodPrint

	@State private var commentText = ""

	var action: ((String) -> Void)?

    var body: some View {
		List {
			Section {
				Text("留言")
			}
			if let comments = foodPrint.comments {
				ForEach(comments) { comment in
					CommentCell(comment: comment)
				}
			} else {
				Text("No comments yet")
			}
		}
		.listStyle(.plain)

		HStack {
			TextField("新增留言...", text: $commentText)
			Button("發布") {
				action?(commentText)
				commentText = ""
			}
			.disabled(commentText.isEmpty)
		}
		.padding(.horizontal, 32)
	}
}

#Preview {
	CommentSheetView(foodPrint: FoodPrint.mockFoodPrint)
}
