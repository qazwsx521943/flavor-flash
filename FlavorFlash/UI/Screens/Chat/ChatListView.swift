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
					.captionBoldStyle()
					.swipeActions(edge: .trailing) {
						Button {
							viewModel.createNewGroup(with: user.id)
						} label: {
							Image(systemName: "plus")
								.resizable()
								.frame(width: 20, height: 20)
						}
						.tint(.lightGreen)
					}
			}
		}
		.listStyle(.plain)
		.searchable(text: $viewModel.searchUserText, placement: .automatic, prompt: Text("search user"))
		.navigationTitle("Creat Chat")
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
