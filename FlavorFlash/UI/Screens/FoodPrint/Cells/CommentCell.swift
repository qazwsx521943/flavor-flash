//
//  CommentCell.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/4.
//

import SwiftUI

struct CommentCell: View {

	let comment: FBComment

    var body: some View {
		HStack(spacing: 10) {
			Image(systemName: "person.fill")

			VStack(alignment: .leading, spacing: 5) {
				HStack {
					Text(comment.userId)
						.font(.caption)
						.bold()

					Text(comment.getRelativeTimeString)
						.font(.caption2)
				}

				Text(comment.comment)
					.font(.caption2)
			}
		}
    }
}

#Preview {
	CommentCell(comment: FoodPrint.mockFoodPrint.comments!.first!)
}
