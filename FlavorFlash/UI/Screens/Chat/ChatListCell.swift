//
//  ChatListCell.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/1.
//

import SwiftUI

struct ChatListCell: View {

	let avatarUrl: String

	let name: String

    var body: some View {
		HStack(spacing: 10) {
			AsyncImage(url: URL(string: avatarUrl)) { image in
				image
					.resizable()
					.scaledToFill()
					.frame(width: 50, height: 50)
					.clipShape(Circle())
			} placeholder: {
				Image(systemName: "person.fill")
					.resizable()
					.frame(width: 50, height: 50)
					.clipShape(Circle())
			}

			Text(name)
				.font(.system(size: 15))
				.bold()

			Spacer()
		}
    }
}

//#Preview {
//    ChatListCell()
//}
