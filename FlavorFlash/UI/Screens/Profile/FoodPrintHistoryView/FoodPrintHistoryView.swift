//
//  FoodPrintHistoryView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/3.
//

import SwiftUI

struct FoodPrintHistoryView: View {

	@ObservedObject var profileViewModel: ProfileViewModel

	@State private var showFriendSelectionView = false

	var body: some View {
		ZStack(alignment: .topLeading) {
			FoodPrintMapView(profileViewModel: profileViewModel)

			Image(systemName: "list.bullet")
				.resizable()
				.frame(width: 20, height: 20)
				.frame(width: 50, height: 50)
				.background(
					Circle()
						.fill(.black.opacity(0.4))
				)
				.padding(.leading, 16)
				.padding(.top, 16)
				.onTapGesture {
					showFriendSelectionView.toggle()
				}

			GeometryReader { geo in
				VStack {
					Text("選擇好友足跡")
						.font(.title2)
						.bold()
						.padding(.top, 16)
					List {
						ForEach(profileViewModel.friends) { friend in
							Text(friend.displayName)
								.font(.title3)
								.bold()
								.tint(.white)
								.onTapGesture {
									Task {
										try await profileViewModel.getFriendFoodPrint(userId: friend.id)
									}
								}
						}
					}
					.listStyle(.plain)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(.black)
				.frame(
					width: geo.size.width,
					height: geo.size.height / 2
				)
				.offset(y: showFriendSelectionView ? geo.size.height / 2 : geo.size.height)
				.animation(.easeIn, value: showFriendSelectionView)
				.transition(.move(edge: .bottom))
			}
		}
		.ignoresSafeArea(edges: .bottom)
		.toolbar(.hidden, for: .tabBar)
		.navigationTitle("My FoodPrints")
		.navigationBarTitleDisplayMode(.inline)
	}
}

//struct FriendFoodPrintSelectionView: View {
//
//	@Binding var friendList: [FFUser]
//
//	var body: some View {
//		VStack {
//			List {
//				ForEach(friendList) { friend in
//					Text(friend.displayName)
//						.font(.title3)
//						.bold()
//						.tint(.white)
//				}
//			}
//		}
//		.frame(maxWidth: .infinity, maxHeight: .infinity)
//		.background(.black.opacity(0.4))
//	}
//}

//#Preview {
//    FoodPrintHistoryView()
//}
