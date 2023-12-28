//
//  DeleteAccountConfirmView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/4.
//

import SwiftUI

struct DeleteAccountConfirmView: View {

	@EnvironmentObject var navigationModel: NavigationModel

	var action: (() -> Void)?

    var body: some View {
		VStack {
			Spacer()

			Text("Are you sure you want to delete your account？")
				.bodyStyle()
				.multilineTextAlignment(.center)

			Spacer()

			Divider()
			Text("Delete Account")
				.bodyStyle()
				.frame(maxWidth: .infinity)
				.padding(.vertical, 12)
				.padding(.horizontal, 16)
				.background(
					RoundedRectangle(cornerRadius: 10)
						.fill(.red)
				)
				.padding(.horizontal, 16)
				.onTapGesture {
					action?()
				}

			Divider()
		}
		.onAppear {
			navigationModel.hideTabBar()
		}
		.onDisappear {
			navigationModel.showTabBar()
		}
		.navigationTitle("Delete Account")
		.navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DeleteAccountConfirmView()
}
