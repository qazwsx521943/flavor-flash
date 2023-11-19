//
//  ChatroomViewCoordinator.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/18.
//

import MessageKit
import InputBarAccessoryView
import UIKit

let sender1 = Sender(senderId: "1", displayName: "Jason")
let sender2 = Sender(senderId: "2", displayName: "Lyy")

final class ChatroomViewCoordinator: NSObject {
    var parent: ChatroomViewController

    init(_ parent: ChatroomViewController) {
        self.parent = parent
    }
}

extension ChatroomViewCoordinator: MessagesDataSource {
    var currentSender: MessageKit.SenderType {
        sender1
    }

    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessageKit.MessagesCollectionView
    ) -> MessageKit.MessageType {
        parent.messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        parent.messages.count
    }
}

extension ChatroomViewCoordinator: MessagesDisplayDelegate {

}
extension ChatroomViewCoordinator: MessagesLayoutDelegate {

}

extension ChatroomViewCoordinator: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !inputBar.inputTextView.text.isEmpty else { return }
        parent.messages.append(
            Message(
                sender: sender1,
                messageId: UUID().uuidString,
                sentDate: Date.now,
                kind: .text(text))
        )

        inputBar.inputTextView.text = ""
    }
}
