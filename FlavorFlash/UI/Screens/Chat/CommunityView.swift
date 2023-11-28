//
//  CommunityView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/14.
//

import SwiftUI

struct CommunityView: View {
	@StateObject private var viewModel = ChatListViewModel()

	var body: some View {
		NavigationStack {
			List {
				if let groups = viewModel.groups {
					ForEach(groups) { group in
						NavigationLink {
							ChatroomView(groupId: group.id)
						} label: {
							Text(group.id)
						}
					}
				}
			}
			.onAppear {
				Task {
					try? await viewModel.loadUser()
					try? await viewModel.getGroups()
				}
			}
		}
	}
}

#Preview {
	CommunityView()
}
