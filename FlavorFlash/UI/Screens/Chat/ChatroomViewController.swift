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
    @Binding var messages: [MessageType]
    typealias UIViewControllerType = MessagesViewController

    func makeUIViewController(context: Context) -> MessageKit.MessagesViewController {
        let messagesViewController = MessagesViewController()

        messagesViewController.messagesCollectionView.messagesDataSource = context.coordinator
        messagesViewController.messagesCollectionView.messagesLayoutDelegate = context.coordinator
        messagesViewController.messagesCollectionView.messagesDisplayDelegate = context.coordinator
        messagesViewController.messageInputBar.delegate = context.coordinator

        return messagesViewController
    }

    func updateUIViewController(_ uiViewController: MessageKit.MessagesViewController, context: Context) {
        uiViewController.messagesCollectionView.reloadData()
        print("update UIViewController")
    }

    func makeCoordinator() -> ChatroomViewCoordinator {
        ChatroomViewCoordinator(self)
    }
}

#Preview {
    ChatroomViewController(messages: .constant(ChatroomViewModel().messages))
}
