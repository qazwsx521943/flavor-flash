//
//  ChatroomView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/18.
//

import SwiftUI
import UIKit
import MessageKit

struct ChatroomViewController: UIViewControllerRepresentable {
//    @Binding var messages: [MessageType]
	@StateObject var chatroomVM: ChatroomViewModel

	init(groupId: String) {
		_chatroomVM = StateObject(wrappedValue: ChatroomViewModel(groupId: groupId))
	}

    typealias UIViewControllerType = MessagesViewController

    func makeUIViewController(context: Context) -> MessageKit.MessagesViewController {
        let messagesViewController = MessagesViewController()

        messagesViewController.messagesCollectionView.messagesDataSource = context.coordinator
        messagesViewController.messagesCollectionView.messagesLayoutDelegate = context.coordinator
        messagesViewController.messagesCollectionView.messagesDisplayDelegate = context.coordinator
		messagesViewController.messageInputBar = CameraInputBarAccessoryView()
		messagesViewController.messageInputBar.delegate = context.coordinator

        return messagesViewController
    }

    func updateUIViewController(_ uiViewController: MessageKit.MessagesViewController, context: Context) {
		DispatchQueue.main.async {
			uiViewController.messagesCollectionView.reloadData()
		}
		scrollToBottom(uiViewController)
        debugPrint("update messageViewController")
    }

    func makeCoordinator() -> ChatroomViewCoordinator {
        ChatroomViewCoordinator(self)
    }
}

extension ChatroomViewController {
	private func scrollToBottom(_ uiViewController: MessagesViewController) {
		DispatchQueue.main.async {
			uiViewController.messagesCollectionView.scrollToLastItem(animated: true)
		}
	}
}

//#Preview {
//    ChatroomViewController(messages: .constant(ChatListViewModel().messages),)
//}
