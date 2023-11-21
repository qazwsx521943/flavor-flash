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


    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
					if let imageUrl = viewModel.user?.photoUrl {
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
                Section("Settings") {
                    ForEach(settingConfigs) { config in
                        NavigationLink(value: config) {
                            Text(config.title)
                        }
                    }
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
				//                        NavigationLink(value: config) {
				NavigationLink(value: config) {
					Text(config.title)
				}
				.foregroundStyle(config.title == "Delete" ? .red : .white)
				//                        }
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
