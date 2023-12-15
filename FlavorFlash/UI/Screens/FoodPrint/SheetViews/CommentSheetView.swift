//
//  CommentSheetView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/4.
//

import SwiftUI

struct CommentSheetView: View {
	let foodPrint: FBFoodPrint

	@State private var commentText = ""

	var action: ((String) -> Void)?

    var body: some View {
		VStack {
			List {
				Section {
					Text("Comment")
						.captionBoldStyle()
						.frame(maxWidth: .infinity)
						.multilineTextAlignment(.center)
				}

				if let comments = foodPrint.comments {
					ForEach(comments) { comment in
						CommentCell(comment: comment)
					}
				} else {
					Text("No comments yet")
				}
			}
			.listRowSeparator(.visible, edges: .bottom)
			.listStyle(.plain)

			Spacer()

			HStack {
				TextField("Leave comment...", text: $commentText)
				Button("Send") {
					action?(commentText)
					commentText = ""
				}
				.tint(.accent)
				.disabled(commentText.isEmpty)
			}
			.padding(.horizontal, 32)
		}
	}
}

#Preview {
	CommentSheetView(foodPrint: FBFoodPrint.mockFoodPrint, action: nil)
}
