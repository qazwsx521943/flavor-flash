//
//  Profile.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/17.
//

import SwiftUI

struct ProfileView: View {
	@StateObject private var viewModel = ProfileViewModel()
	@EnvironmentObject private var navigationModel: NavigationModel

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 100, height: 100)

                }
				if let user = viewModel.user {
					VStack {
						Text(user.userId)
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
