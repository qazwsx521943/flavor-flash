//
//  FoodPrintHistoryView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/3.
//

import SwiftUI

struct FoodPrintHistoryView: View {

	@ObservedObject var profileViewModel: ProfileViewModel

	@EnvironmentObject var navigationModel: NavigationModel

	@State private var showFriendSelectionView = false

	@State private var showFriendPost = false

	@State private var selectedFoodPrint: FBFoodPrint?

	var body: some View {
		ZStack(alignment: .topLeading) {
			FoodPrintMapView(profileViewModel: profileViewModel) { foodPrint in
				selectedFoodPrint = foodPrint
				showFriendPost.toggle()
			}

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
					Text("Select Foodprint")
						.bodyBoldStyle()
						.padding(.top, 16)
					List {
						ForEach(profileViewModel.friends) { friend in
							Text(friend.displayName)
								.captionBoldStyle()
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
		.sheet(isPresented: $showFriendPost, content: {
			if let selectedFoodPrint {
				VStack(alignment: .center) {
					FoodPrintCell(foodPrint: selectedFoodPrint, likePost: {

					}, dislikePost: {
						
					}, hideActionTab: true)
					.frame(maxWidth: .infinity)
					.frame(height: 250)
					.padding(.horizontal, 8)
				}
				.padding()
				.presentationDetents([.medium, .large])
			}
		})
		.onAppear {
			navigationModel.hideTabBar()
		}
		.onDisappear {
			navigationModel.showTabBar()
		}
		.ignoresSafeArea(edges: .bottom)
		.toolbar(.hidden, for: .tabBar)
		.toolbar {
			NavigationBarBackButton()
		}
		.navigationBarBackButtonHidden()
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
