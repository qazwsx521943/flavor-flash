//
//  Profile.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct ProfileView: View {

	@StateObject private var viewModel = ProfileViewModel()

	@EnvironmentObject private var navigationModel: NavigationModel

	@State private var selectedItem: PhotosPickerItem?

	@State private var showQRCode = false

	@State private var qrCodeMode: QRCodeMode = .myQRCode

	@State private var showFriends = false

	@State private var showFoodPrint = false


	enum QRCodeMode: Int {
		case myQRCode = 0
		case scanQRCode = 1
	}

	var body: some View {
		NavigationStack {

			if let user = viewModel.user {
				ProfileHeader(
					avatarUrlString: user.profileImageUrl ?? "",
					displayName: user.displayName
				) {
					ActivityItemDisplay(title: "foodprints", count: viewModel.foodPrints.count) {
						showFoodPrint = true
					}
					ActivityItemDisplay(title: "badges", count: 0)
					ActivityItemDisplay(title: "friends", count: viewModel.friends.count) {
						showFriends = true
					}
				}
				.onAppear {
					Task {
						do {
							try await viewModel.getAllFriends()
						} catch {
							debugPrint("error")
						}
					}
				}
				.padding(.horizontal, 16)
				.padding(.top, 50)
				.navigationDestination(isPresented: $showFriends) {
					List {
						ForEach(viewModel.friends, id: \.self) { friend in
							HStack {
								KFImage(URL(string: friend.profileImageUrl ?? ""))
									.placeholder {
										Image(systemName: "person.fill")
									}
									.resizable()
									.scaledToFill()
									.frame(width: 50, height: 50)
									.clipShape(Circle())

								Text(friend.displayName)

								Spacer()

								Text("...")
									.bodyStyle()
									.contextMenu {
										Button(role: .destructive) {
											viewModel.deleteFriend(friend.id)
										} label: {
											Text("Delete")
										}

										Button(role: .destructive) {
											viewModel.blockFriend(friend.id)
										} label: {
											Text("Block")
										}

									} preview: {
										KFImage(URL(string: friend.profileImageUrl ?? ""))
											.placeholder {
												Image(systemName: "person.fill")
											}
											.resizable()
											.frame(width: 200, height: 200)
									}
							}
						}
					}
					.listStyle(.plain)
					.toolbar {
						NavigationBarBackButton()
					}
					.navigationBarBackButtonHidden()
					.navigationTitle("Friends")
					.navigationBarTitleDisplayMode(.inline)
				}
				.navigationDestination(isPresented: $showFoodPrint) {
					FoodPrintHistoryView(profileViewModel: viewModel)
				}
			}

			List {
				Section {
					Toggle(isOn: $navigationModel.preferDarkMode) {
						Text("Dark Mode")
							.prefixedWithSFSymbol(named: "circle.lefthalf.filled", height: 20)
							.captionStyle()
					}
					.toggleStyle(PrimaryToggleStyle(size: 16))
				} header: {
					Text("Appearance")
						.captionStyle()
				}
				// QRCODE Section
				Section {
					qrcodeView
				} header: {
					Text("Social")
						.captionStyle()
				}

				accountConfigurationView
			}
			.environmentObject(viewModel)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					NavigationLink {
						SettingsView(profileViewModel: viewModel)
					} label: {
						Image(systemName: "gearshape.fill")
							.tint(.secondary)
					}
				}
			}
			.navigationTitle("Profile")
			.navigationBarTitleDisplayMode(.inline)
			.refreshable {
				viewModel.loadProfileData()
			}
		}
	}
}

extension ProfileView {
	// MARK: - Layout
	private var avatarInfo: some View {
		ZStack(alignment: .center) {
			//			if let user = viewModel.user {
			//				VStack(alignment: .leading) {
			//					Text(user.displayName)
			//						.padding(.leading, 12)
			//						.font(.title)
			//						.bold()


			//				}
			//				.frame(maxWidth: .infinity, maxHeight: 100)
			Rectangle()
				.frame(width: .infinity, height: 100)
				.background(Color.gray)

			avatarImage
			//			}
		}
		.frame(height: 100)
		.padding(.horizontal, 16)
		.task {
			try? await viewModel.loadCurrentUser()
		}
		.onChange(of: selectedItem) { selected in
			guard let selected else {
				return
			}
			viewModel.saveProfileImage(item: selected)
		}
	}

	private var accountConfigurationView: some View {
		Section {
			HStack {
				Spacer()

				Button {
					do {
						try viewModel.logOut()
						navigationModel.showSignInModal = true
						debugPrint("logged out")
					} catch {
						debugPrint("Logged Out Error")
					}
				} label: {
					Text("Logout")
						.bodyBoldStyle()
						.foregroundStyle(.red)
				}

				Spacer()
			}
		}
	}

	private var qrcodeView: some View {
		Text("Add Friends")
			.prefixedWithSFSymbol(named: "qrcode", height: 20, tintColor: .white)
			.captionStyle()
			.onTapGesture {
				showQRCode = true
			}
			.sheet(isPresented: $showQRCode) {
				VStack(spacing: 50) {
					Picker("QRCode scanner", selection: $qrCodeMode) {
						Text("Show QRCode").tag(QRCodeMode.myQRCode)
						Text("Scan QRCode").tag(QRCodeMode.scanQRCode)
					}
					.pickerStyle(.segmented)
					.padding(.horizontal, 16)

					if qrCodeMode == .myQRCode {
						VStack(alignment: .center) {
							if let userId = viewModel.user?.id {
								Image(uiImage: viewModel.generateQRCode(from: userId))
									.interpolation(.none)
									.resizable()
									.scaledToFit()
									.frame(width: 150, height: 150)
							}
						}
					} else {
						if
							let searchedUser = viewModel.searchedUser
						{
							HStack {
								AsyncImage(url: URL(string: searchedUser.profileImageUrl ?? "")) { phase in
									switch phase {
									case .success(let image):
										image
											.resizable()
											.scaledToFill()
											.frame(width: 50, height: 50)
											.clipShape(Circle())

									case .failure:
										Image(systemName: "person.fill")
											.resizable()
											.frame(width: 50, height: 50)
									case .empty:
										Image(systemName: "person.fill")
											.resizable()
											.frame(width: 50, height: 50)
									@unknown default:
										Image(systemName: "person.fill")
											.resizable()
											.frame(width: 50, height: 50)
									}
								}

								Text(searchedUser.displayName)
									.captionBoldStyle()

								Spacer()

								HStack {
									let isFriend = viewModel.friends.contains(searchedUser)
									Button {
										Task {
											guard let searchedUser = viewModel.searchedUser else { return }
											try await viewModel.sendRequest(to: searchedUser.id)
										}
									} label: {
										Text(isFriend ? "Added" : "Add")
											.captionStyle()
											.foregroundStyle(.white)
									}
									.buttonStyle(SmallPrimaryButtonStyle())
									.disabled(isFriend)

									Button {
										viewModel.searchedUser = nil
									} label: {
										Image(systemName: "xmark")
											.captionStyle()
									}
									.buttonStyle(IconButtonStyle())
								}
							}
						} else {
							CodeScannerView(codeTypes: [.qr]) { response in
								switch response {
								case .success(let result):
									Task {
										debugPrint("codescanner: \(result.string)")
										viewModel.searchedUser = try await viewModel.getUser(userId: result.string)
									}
								case .failure(let error):
									debugPrint(error.localizedDescription)
								}
							}
							.frame(width: 300, height: 300)
						}
					}

					Spacer()
				}
				.padding(.horizontal, 32)
				.padding(.top, 80)
				.frame(alignment: .top)
			}
	}

	private var avatarImage: some View {
		ZStack {
			if let imageUrl = viewModel.user?.profileImageUrl {
				AsyncImage(url: URL(string: imageUrl)) { image in
					image
						.resizable()
						.scaledToFill()
				} placeholder: {
					ProgressView()
				}
				.frame(width: 80, height: 80)
				.clipShape(Circle())
			} else {
				Circle()
					.frame(width: 80, height: 80)
			}
		}
		.overlay(alignment: .bottomTrailing) {
			PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
				Image(systemName: "pencil.circle.fill")
					.symbolRenderingMode(.multicolor)
					.font(.system(size: 30))
					.foregroundColor(Color.purple)
			}
		}
	}

	// unused
	private var showFriendLink: some View {
		NavigationLink {
			ScrollView {
				VStack {
					ForEach(viewModel.friends, id: \.self) { friend in
						HStack {
							KFImage(URL(string: friend.profileImageUrl ?? ""))
								.placeholder {
									Image(systemName: "person.fill")
								}
								.resizable()
								.scaledToFill()
								.frame(width: 50, height: 50)
								.clipShape(Circle())

							Text(friend.displayName)

							Spacer()

							Button {

							} label: {
								Text("...")
									.bodyStyle()
									.contextMenu {
										Button(role: .destructive) {

										} label: {
											Text("Delete")
										}

										Button(role: .destructive) {

										} label: {
											Text("Block")
										}

									} preview: {
										KFImage(URL(string: friend.profileImageUrl ?? ""))
									}
							}
							.buttonStyle(SmallPrimaryButtonStyle())
						}
					}
				}
			}
			.onAppear {
				Task {
					do {
						try await viewModel.getAllFriends()
					} catch {
						debugPrint("error")
					}
				}
			}
			.toolbar {
				NavigationBarBackButton()
			}
			.navigationBarBackButtonHidden()
			.navigationTitle("Friends")
			.navigationBarTitleDisplayMode(.inline)
		} label: {
			if let user = viewModel.user {
				Text("\(user.friends?.count ?? 0) Friends")
					.prefixedWithSFSymbol(named: "person.fill", height: 15)
					.font(.subheadline)
					.foregroundStyle(.white)
			}
		}
	}
}

#Preview {
	NavigationStack {
		ProfileView()
	}
}
