//
//  ChatroomView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/28.
//

import SwiftUI
import ExyteChat

struct ChatroomView: View {
	@EnvironmentObject var navigationModel: NavigationModel

	@StateObject private var chatroomViewModel: ChatroomViewModel

	private var theme: ChatTheme {
		return ChatTheme(colors: ChatTheme.Colors(
			mainBackground: navigationModel.preferDarkMode ? .black : .white,
			sendButtonBackground: .lightGreen,
			myMessage: .darkGreen
		))
	}

	var body: some View {
		ChatView(messages: chatroomViewModel.messages) { message in
			chatroomViewModel.sendMessage(message: message)
		}
		.customChatNavigation(theme: theme, title: chatroomViewModel.chatroomTitle)
		.chatTheme(theme)
		.font(.custom("Futura", size: 14))
		.onAppear {
			navigationModel.hideTabBar()
		}
		.onDisappear {
			navigationModel.showTabBar()
		}
		//		.toolbar(.hidden, for: .tabBar)
	}

	init(groupId: String) {
		_chatroomViewModel = StateObject(wrappedValue: ChatroomViewModel(groupId: groupId))
	}
}

extension ChatView {
	func customChatNavigation(theme: ChatTheme, title: String, status: String? = nil, cover: URL? = nil) -> some View {

		modifier(CustomChatNavigationModifier(theme: theme, title: title, status: status, cover: cover))
	}
}

struct CustomChatNavigationModifier: ViewModifier {
	@Environment(\.presentationMode) private var presentationMode

	@Environment(\.colorScheme) private var colorScheme

	let theme: ChatTheme
	let title: String
	let status: String?
	let cover: URL?

	func body(content: Content) -> some View {
		content
			.navigationBarBackButtonHidden()
			.toolbar {
				backButton
				infoToolbarItem
			}
	}

	private var backButton: some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Button { presentationMode.wrappedValue.dismiss() } label: {
				Image(systemName: "arrowtriangle.left.fill")
					.foregroundColor(colorScheme == .light ? Color.black : .white)
					.bodyBoldStyle()
			}
		}
	}

	private var infoToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .principal) {
			HStack {
				//				if let url = cover {
				//					AsyncImage(url: url) { phase in
				//						switch phase {
				//						case .success(let image):
				//							image
				//								.resizable()
				//								.scaledToFill()
				//						default:
				//							Rectangle().fill(theme.colors.grayStatus)
				//						}
				//					}
				//					.frame(width: 35, height: 35)
				//					.clipShape(Circle())
				//				}

				VStack(alignment: .leading, spacing: 0) {
					Text(title)
						.bodyStyle()
						.foregroundColor(colorScheme == .light ? Color.black : .white)
					if let status = status {
						Text(status)
							.font(.footnote)
							.foregroundColor(theme.colors.grayStatus)
					}
				}
				Spacer()
			}
			.padding(.leading, 10)
		}
	}
}

//#Preview {
//    ChatroomView()
//}
