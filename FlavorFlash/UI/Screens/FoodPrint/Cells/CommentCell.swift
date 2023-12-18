//
//  CommentCell.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/4.
//

import SwiftUI
import Kingfisher

struct CommentCell: View {

	let comment: FBComment

    var body: some View {
		HStack(spacing: 10) {
			KFImage(URL(string: comment.userProfileImage ?? ""))
				.placeholder {
					Image(systemName: "person.fill")
				}
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: 30, height: 30)
				.clipShape(Circle())

			VStack(alignment: .leading, spacing: 5) {
				HStack {
					Text(comment.username)
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
	CommentCell(comment: FBFoodPrint.mockFoodPrint.comments!.first!)
}
