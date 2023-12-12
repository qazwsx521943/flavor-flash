//
//  SettingsView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/4.
//

import SwiftUI

struct SettingsView: View {
	@ObservedObject var profileViewModel: ProfileViewModel

	@EnvironmentObject var navigationModel: NavigationModel

    var body: some View {
		List {
			NavigationLink {
				accountSettingList
			} label: {
				Text("Account")
					.prefixedWithSFSymbol(named: "person.crop.circle", height: 20)
					.bodyStyle()
			}

			NavigationLink {
				privacySettingList
			} label: {
				Text("Privacy Setting")
					.prefixedWithSFSymbol(named: "lock", height: 20)
					.bodyStyle()
			}
		}
		.listStyle(.plain)
		.toolbar(.hidden, for: .tabBar)
		.navigationTitle("Settings")
		.navigationBarTitleDisplayMode(.inline)
    }
}

extension SettingsView {
	private var privacySettingList: some View {
		List {
			NavigationLink {
				List {
					ForEach(profileViewModel.blockedUsers) { user in
						Text(user.displayName)
							.bodyStyle()
					}
				}
				.navigationTitle("Blocked Users")
			} label: {
				Text("Blocked Users")
			}

		}
		.listStyle(.plain)
		.navigationTitle("Privacy Settings")
		.navigationBarTitleDisplayMode(.inline)
	}

	private var accountSettingList: some View {
		List {
			Button {
				Task {
					do {
						try await profileViewModel.resetPassword()
					} catch {
						debugPrint("Reset password error")
					}
				}
			} label: {
				Text("重設密碼")
					.foregroundStyle(.primary)
			}

			NavigationLink {
				DeleteAccountConfirmView {
					profileViewModel.deleteAccount()
					navigationModel.showSignInModal = true
				}
			} label: {
				Text("刪除帳號")
			}
		}
		.listStyle(.plain)
		.navigationTitle("Account Settings")
		.navigationBarTitleDisplayMode(.inline)

	}
}

//#Preview {
//	NavigationStack {
//		SettingsView()
//	}
//}
