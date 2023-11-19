//
//  CommunityView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI

let channels = ["steven", "jason", "jimmy"]

struct CommunityView: View {
    @StateObject private var viewModel = ChatroomViewModel()
    var body: some View {
//        Group {
//            ForEach(channels, id: \.self) { channel in
//                Text(channel)
//            }
//        }
        ChatroomViewController(messages: $viewModel.messages)
    }
}

#Preview {
    CommunityView()
}
