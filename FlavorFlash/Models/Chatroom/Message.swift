//
//  Message.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/18.
//

import MessageKit
import Foundation

struct Message: MessageType {
    var sender: MessageKit.SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKit.MessageKind
}
