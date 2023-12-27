//
//  LiveStreamView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/25.
//

import SwiftUI

struct LiveStreamView: View {
	@StateObject private var viewModel = LiveStreamViewModel()

	var body: some View {
		NavigationStack {

			VStack {
				if let streamId = viewModel.streamId {
					HStack {
						Text("Your stream ID: ")

						Text(streamId)
							.onTapGesture(count: 2) {
								UIPasteboard.general.string = streamId
							}
					}
				}

				ForEach(viewModel.streamIds, id: \.self) { id in
					Button(id) {
						viewModel.streamId = id
						viewModel.joinStream(id: id)
					}
					.buttonStyle(SmallPrimaryButtonStyle())
				}

				Button {
					viewModel.createStream()
				} label: {
					Text("Start Stream")
				}
				.buttonStyle(LargePrimaryButtonStyle())

				NavigationLink {
					viewModel.buildVideoVC()
						.frame(maxWidth: .infinity)
						.frame(maxHeight: .infinity)
				} label: {
					Text("Open Camera")
				}
			}
		}
	}
}

#Preview {
	LiveStreamView()
}
