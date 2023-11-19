//
//  ChatroomViewModel.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import Foundation
import MessageKit

final class ChatroomViewModel: ObservableObject {
    @Published var messages: [MessageType] = [
        Message(sender: sender1, messageId: "1", sentDate: Date.now, kind: .text("hi")),
        Message(sender: sender1, messageId: "2", sentDate: Date.now, kind: .text("cool")),
        Message(sender: sender2, messageId: "3", sentDate: Date.now, kind: .text("how are you")),
        Message(sender: sender1, messageId: "4", sentDate: Date.now, kind: .text("good!"))
    ]
}
