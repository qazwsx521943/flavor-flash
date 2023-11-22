//
//  ChatroomView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/18.
//

import SwiftUI
import UIKit
import MessageKit

final class MessageSwiftUIVC: MessagesViewController {
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		// Because SwiftUI wont automatically make our controller the first responder, we need to do it on viewDidAppear
		becomeFirstResponder()
		messagesCollectionView.scrollToLastItem(animated: true)
	}
}

struct ChatroomViewController: UIViewControllerRepresentable {
	
//    @Binding var messages: [MessageType]
	@StateObject var chatroomVM: ChatroomViewModel

	init(groupId: String) {
		_chatroomVM = StateObject(wrappedValue: ChatroomViewModel(groupId: groupId))
	}

    typealias UIViewControllerType = MessageSwiftUIVC

    func makeUIViewController(context: Context) -> MessageSwiftUIVC {
        let messagesViewController = MessageSwiftUIVC()

        messagesViewController.messagesCollectionView.messagesDataSource = context.coordinator
        messagesViewController.messagesCollectionView.messagesLayoutDelegate = context.coordinator
        messagesViewController.messagesCollectionView.messagesDisplayDelegate = context.coordinator
//		messagesViewController.messageInputBar = CameraInputBarAccessoryView()
		messagesViewController.messageInputBar.delegate = context.coordinator
		messagesViewController.scrollsToLastItemOnKeyboardBeginsEditing = true // default false
		messagesViewController.maintainPositionOnInputBarHeightChanged = true // default false
		messagesViewController.showMessageTimestampOnSwipeLeft = true // default false

        return messagesViewController
    }

    func updateUIViewController(_ uiViewController: MessageSwiftUIVC, context: Context) {
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
