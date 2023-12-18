//
//  ChatListCell.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/1.
//

import SwiftUI
import Kingfisher

struct ChatListCell: View {

	let avatarUrl: String

	let name: String

    var body: some View {
		HStack(spacing: 10) {

			KFImage(URL(string: avatarUrl))
				.placeholder {
					Image(systemName: "person.fill")
				}
				.resizable()
				.scaledToFill()
				.frame(width: 40, height: 40)
				.clipShape(Circle())

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
