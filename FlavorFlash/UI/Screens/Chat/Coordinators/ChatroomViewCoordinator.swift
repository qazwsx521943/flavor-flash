//
//  ChatroomViewCoordinator.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/18.
//

import MessageKit
import InputBarAccessoryView
import UIKit

final class ChatroomViewCoordinator: NSObject {
    var parent: ChatroomViewController

    init(_ parent: ChatroomViewController) {
        self.parent = parent
    }
}

extension ChatroomViewCoordinator: MessagesDataSource {
    var currentSender: MessageKit.SenderType {
		Sender(senderId: parent.chatroomVM.user!.userId, displayName: "Jason")
    }

    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessageKit.MessagesCollectionView
    ) -> MessageKit.MessageType {
		parent.chatroomVM.messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
		parent.chatroomVM.messages.count
    }

	// message attributes
	func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let name = message.sender.displayName

		return NSAttributedString(
			string: name,
			attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
	}

	func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let dateString = DateFormatter.formatter.string(from: message.sentDate)

		return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption2)])
	}
}

extension ChatroomViewCoordinator: MessagesDisplayDelegate {
	func backgroundColor(
		for message: MessageType,
		at indexPath: IndexPath,
		in messagesCollectionView: MessagesCollectionView
	) -> UIColor {
		.systemPurple
	}

	func messageStyle(
		for message: MessageType,
		at indexPath: IndexPath,
		in messagesCollectionView: MessagesCollectionView
	) -> MessageStyle {
		MessageStyle.bubbleTail(
			message.sender.senderId == currentSender.senderId ? .bottomRight : .bottomLeft,
				.curved)
	}

	func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
		.white
	}

	func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
		if message.sender.senderId == currentSender.senderId {
			guard let profileImageUrl = parent.chatroomVM.user?.profileImageUrl else { return }
			UIImageView.getUIImage(urlString: profileImageUrl) { image in
				avatarView.set(avatar: Avatar(image: image))
			}
		} else {
			guard let profileImageUrl = parent.chatroomVM.members?.first(where: { user in
				user.userId == message.sender.senderId
			})?.profileImageUrl else {
				avatarView.set(avatar: Avatar(image: UIImage(named: "home-icon")))
				return
			}

			UIImageView.getUIImage(urlString: profileImageUrl) { image in
				avatarView.set(avatar: Avatar(image: image))
			}
		}
	}
}
extension ChatroomViewCoordinator: MessagesLayoutDelegate {
	func messageTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
		20
	}

	func messageBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
		16
	}
}

extension ChatroomViewCoordinator: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !inputBar.inputTextView.text.isEmpty else { return }
		Task {
			try await parent.chatroomVM.sendMessage(text: text)
		}

        inputBar.inputTextView.text = ""
    }
}
