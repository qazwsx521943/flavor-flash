//
//  ChatroomView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/28.
//

import SwiftUI
import ExyteChat

struct ChatroomView: View {

	@StateObject private var chatroomViewModel: ChatroomViewModel

    var body: some View {
		ChatView(messages: chatroomViewModel.messages) { message in
			chatroomViewModel.sendMessage(text: message.text)
		}
    }

	init(groupId: String) {
		_chatroomViewModel = StateObject(wrappedValue: ChatroomViewModel(groupId: groupId))
	}
}

//#Preview {
//    ChatroomView()
//}
