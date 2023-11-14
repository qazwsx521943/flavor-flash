//
//  Item.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
