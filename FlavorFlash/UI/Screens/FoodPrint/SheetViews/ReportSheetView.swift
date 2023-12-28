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
					Text("Report")
						.captionBoldStyle()
						.frame(maxWidth: .infinity)
						.padding(.vertical, 8)
						.multilineTextAlignment(.center)

					ForEach(ReportReason.allCases, id: \.self) { reason in
						Text(reason.title)
							.captionStyle()
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
		Text("We have received your report, and will review this foodPrint ASAP!")
			.bodyStyle()
			.multilineTextAlignment(.center)
	}
}

#Preview {
	NavigationStack {
		ReportSheetView()
	}
}
