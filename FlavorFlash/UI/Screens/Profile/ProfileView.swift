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
	@State private var foundedUser: FFUser?

	enum QRCodeMode: Int {
		case myQRCode = 0
		case scanQRCode = 1
	}

	var body: some View {
		NavigationStack {
			VStack {
				ZStack {
					if let imageUrl = viewModel.user?.profileImageUrl {
						AsyncImage(url: URL(string: imageUrl)) { image in
							image
								.resizable()
								.scaledToFill()
								.frame(width: 100, height: 100)
								.clipShape(Circle())
						} placeholder: {
							ProgressView()
						}
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
					VStack {
						Text(user.displayName)
							.font(.title)
							.bold()
						Text("美食獵人")
							.font(.subheadline)
							.foregroundStyle(.gray)
					}
				}
			}
			.task {
				try? await viewModel.loadCurrentUser()
			}
			.onChange(of: selectedItem) { selected in
				guard let selected else {
					return
				}
				viewModel.saveProfileImage(item: selected)
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
								if let qrCodeData = viewModel.qrCodeImageData {
									Image(uiImage: UIImage(data: qrCodeData)!)
								}
							}
						} else {
							if
								let searchedUser = foundedUser,
								let profileImageUrl = searchedUser.profileImageUrl
							{
								HStack {
									AsyncImage(url: URL(string: profileImageUrl)) { phase in
										switch phase {
										case .success(let image):
											image
												.resizable()
												.scaledToFit()
												.frame(width: 100, height: 100)
										case .failure(_):
											Image(systemName: "person.fill")
												.resizable()
												.frame(width: 100, height: 100)
										case .empty:
											Image(systemName: "person.fill")
												.resizable()
												.frame(width: 100, height: 100)
										@unknown default:
											Image(systemName: "person.fill")
												.resizable()
												.frame(width: 100, height: 100)
										}
									}

									Text(searchedUser.displayName)

									Spacer()

									Button {
										debugPrint("\(searchedUser.displayName) is  added to your friend list")
										foundedUser = nil
									} label: {
										Text("Add")
											.padding()
											.foregroundStyle(.white)
									}
									.frame(width: 100, height: 50)
									.background(Color.purple)
									.clipShape(RoundedRectangle(cornerRadius: 10))

								}
							} else {
								CodeScannerView(codeTypes: [.qr]) { response in
									switch response {
									case .success(let result):
										Task {
											foundedUser = try await viewModel.getUser(userId: result.string)
										}
									case .failure(let error):
										debugPrint(error.localizedDescription)
									}
								}
								.frame(width: 300, height: 300)
							}
						}
					}
					.padding(.horizontal, 32)
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
					.foregroundStyle(.purple)
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
					.foregroundStyle(.red)
			}
		}
	}
}

#Preview {
	ProfileView()
}
