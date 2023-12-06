//
//  Profile.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {

	@StateObject private var viewModel = ProfileViewModel()

	@EnvironmentObject private var navigationModel: NavigationModel

	@State private var selectedItem: PhotosPickerItem? = nil

	@State private var showQRCode = false

	@State private var qrCodeMode: QRCodeMode = .myQRCode

	@State private var showFriends = false
	@State private var showFoodPrint = false
	@State private var isDarkMode = false

	enum QRCodeMode: Int {
		case myQRCode = 0
		case scanQRCode = 1
	}

	var body: some View {
			if let user = viewModel.user {
				ProfileHeader(avatarUrlString: user.profileImageUrl ?? "") {
					ActivityItemDisplay(title: "foodprints", count: viewModel.foodPrints.count) {
						showFoodPrint = true
					}
					ActivityItemDisplay(title: "badges", count: 8)
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
								AsyncImage(url: URL(string: friend.profileImageUrl ?? "")) { image in
									image
										.resizable()
										.scaledToFill()
								} placeholder: {
									Image(systemName: "person.fill")
								}
								.frame(width: 50, height: 50)
								.clipShape(Circle())

								Text(friend.displayName)
							}
						}
					}
					.navigationTitle("Friends")
					.navigationBarTitleDisplayMode(.inline)
				}
				.navigationDestination(isPresented: $showFoodPrint) {
					FoodPrintHistoryView(profileViewModel: viewModel)
				}
			}

			List {
				Section {
					Toggle(isOn: $isDarkMode) {
						Text("Dark Mode")
							.prefixedWithSFSymbol(named: "circle.lefthalf.filled", height: 20)
							.captionStyle()
					}
						.toggleStyle(PrimaryToggleStyle(size: 16))
				} header: {
					Text("Appearance")
						.captionStyle()
				}

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
						Text("顯示QRCode").tag(QRCodeMode.myQRCode)
						Text("掃描QRCode").tag(QRCodeMode.scanQRCode)
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

									case .failure(_):
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

								Spacer()

								VStack(alignment: .center, spacing: 4) {
									Button {
										viewModel.searchedUser = nil
									} label: {
										Text("取消")
											.font(.caption)
											.padding(8)
											.foregroundStyle(.white)
									}
									.frame(width: 80, height: 40)
									.backgroundStyle(Color.black.opacity(0.7))
									.clipShape(RoundedRectangle(cornerRadius: 10))
									.border(Color.white, width: 2)

									Button {
										Task {
											guard let searchedUser = viewModel.searchedUser else { return }
											try await viewModel.sendRequest(to: searchedUser.id)
										}
									} label: {
										Text("加入")
											.font(.caption)
											.padding(8)
											.foregroundStyle(.white)
									}
									.frame(width: 80, height: 40)
									.background(Color.purple)
									.clipShape(RoundedRectangle(cornerRadius: 10))
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
			List {
				ForEach(viewModel.friends, id: \.self) { friend in
					HStack {
						AsyncImage(url: URL(string: friend.profileImageUrl ?? "")) { image in
							image
								.resizable()
								.scaledToFill()
						} placeholder: {
							Image(systemName: "person.fill")
						}
						.frame(width: 50, height: 50)
						.clipShape(Circle())

						Text(friend.displayName)
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
