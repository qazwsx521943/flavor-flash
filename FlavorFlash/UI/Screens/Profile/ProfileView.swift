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

	enum QRCodeMode: Int {
		case myQRCode = 0
		case scanQRCode = 1
	}

	var body: some View {
		NavigationStack {
			VStack {
				HStack {
					ZStack {
						if let imageUrl = viewModel.user?.profileImageUrl {
							AsyncImage(url: URL(string: imageUrl)) { image in
								image
									.resizable()
									.scaledToFill()
							} placeholder: {
								ProgressView()
							}
							.frame(width: 100, height: 100)
							.clipShape(Circle())
						} else {
							Circle()
								.frame(width: 100, height: 100)
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
					if let user = viewModel.user {
						VStack(alignment: .leading) {
							Text(user.displayName)
								.padding(.leading, 12)
								.font(.title)
								.bold()
							Text("美食獵人")
								.padding(.leading, 12)
								.font(.subheadline)
								.foregroundStyle(.gray)

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
								Text("\(user.friends?.count ?? 0) Friends")
									.prefixedWithSFSymbol(named: "person.fill", height: 15)
									.font(.subheadline)
									.foregroundStyle(.white)
							}
						}
					}

					Spacer()
				}
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

			List {
				//                Section("Settings") {
				//                    ForEach(settingConfigs) { config in
				//                        NavigationLink(value: config) {
				//                            Text(config.title)
				//                        }
				//                    }
				//
				//                }
				Section("FoodPrint") {
					NavigationLink {
						Text("hi")
					} label: {
						Text("FoodPrint")
							.prefixedWithSFSymbol(named: "shoeprints.fill", height: 20)
					}
				}

				Section("Social") {
					qrcodeView
				}

				accountConfigurationView
			}
			.navigationDestination(for: SettingItem.self) { setting in
				Text(setting.title)
			}
			.navigationDestination(for: AccountConfigs.self) { config in
				Button(config.title) {

				}
				.padding()
			}
		}
	}
}

extension ProfileView {
	private var accountConfigurationView: some View {
		Section("Account") {
			ForEach(accountConfigs) { config in
				NavigationLink(value: config) {
					Text(config.title)
				}
				.foregroundStyle(config.title == "Delete" ? .red : .white)
			}

			Button {
				Task {
					do {
						try await viewModel.resetPassword()
					} catch {
						debugPrint("Reset password error")
					}
				}
			} label: {
				Text("Reset Password")
					.prefixedWithSFSymbol(named: "square.and.pencil", height: 20)
					.foregroundStyle(.primary)
			}

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
					.prefixedWithSFSymbol(named: "rectangle.portrait.and.arrow.right", height: 20, tintColor: .red)
					.foregroundStyle(.red)
			}
		}
	}

	private var qrcodeView: some View {
		Text("掃描QRCode")
			.prefixedWithSFSymbol(named: "qrcode", height: 20, tintColor: .white)
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
}

#Preview {
	ProfileView()
}
