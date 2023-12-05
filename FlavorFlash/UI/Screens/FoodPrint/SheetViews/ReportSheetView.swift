//
//  ReportSheetView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/4.
//

import SwiftUI

struct ReportSheetView: View {
	var action: ((ReportReason) -> Void)?

	@State private var reasonSelected = false
	var body: some View {
		GeometryReader { geo in
			if reasonSelected {
				ReportResultView()
					.frame(maxWidth: .infinity)
					.frame(height: geo.size.height)
					.transition(.slide)
					.animation(.default, value: reasonSelected)
			} else {
				List {
					Section {
						Text("檢舉")
							.frame(maxWidth: .infinity)
							.multilineTextAlignment(.center)
					}

					ForEach(ReportReason.allCases, id: \.self) { reason in
						Text(reason.title)
							.onTapGesture {
								action?(reason)
								reasonSelected = true
							}
					}
				}
				.listStyle(.inset)
			}
		}
	}
}

struct ReportResultView: View {
	var body: some View {
		Text("我們已收到你的檢舉，即將審核這篇文章。")


	}
}

#Preview {
	NavigationStack {
		ReportSheetView()
	}
}
