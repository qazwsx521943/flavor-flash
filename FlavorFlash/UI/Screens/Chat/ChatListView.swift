//
//  CommunityView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI

struct ChatListView: View {
	@StateObject private var viewModel = ChatListViewModel()

	var body: some View {
		NavigationStack {
			Group {
				if 
					let currentUser = viewModel.user,
					!viewModel.groups.isEmpty {
					List {
						ForEach(viewModel.groups) { group in
							NavigationLink {
								ChatroomView(groupId: group.id)
							} label: {
								ChatListCell(
									avatarUrl: group.getGroupImage(exclude: currentUser.id),
									name: group.name
								)
									.frame(height: 60)
							}
						}
					}
					.listStyle(.plain)
				} else {
					Text("No Chats yet")
				}
			}
			.onAppear {
				Task {
					try? await viewModel.loadUser()
					try? await viewModel.getGroups()
				}
			}
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					NavigationLink {
						addNewChat
					} label: {
						Image(systemName: "plus")
							.foregroundStyle(.darkGreen)
					}
				}

				NavigationBarBackButton()
			}
			.navigationBarBackButtonHidden()
			.navigationTitle("Chat")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

extension ChatListView {
	// MARK: - Layout
	var addNewChat: some View {
		List {
			ForEach(viewModel.searchedResult) { user in
				Text(user.displayName)
					.swipeActions(edge: .trailing) {
						Button {
							viewModel.createNewGroup(with: user.id)
						} label: {
							Image(systemName: "plus")
								.resizable()
								.frame(width: 20, height: 20)
						}
					}
			}
		}
		.listStyle(.plain)
		.searchable(text: $viewModel.searchUserText, placement: .automatic, prompt: Text("search user"))
		.navigationTitle("Add Chatroom")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			NavigationBarBackButton()
		}
		.navigationBarBackButtonHidden()
	}
}

#Preview {
	ChatListView()
}
