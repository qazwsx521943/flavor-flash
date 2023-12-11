//
//  TextEditorView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/11.
//

import SwiftUI

struct TextEditorView: View {

	@Binding var showEditorView: Bool

	@State private var text: String = ""

	@State private var fontStyle: FontStyle = .academyEngraved

	@State private var backgroundColor: Color = .red

	var action: (AnyView) -> Void

	var body: some View {
		VStack {
			TextField(text: $text) {

			}
			.foregroundStyle(.shadowGray)
			.font(.custom(fontStyle.rawValue, size: 20))
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 10)
					.fill(backgroundColor)
			)

			Text("Current Color: \(backgroundColor.description)")
				.foregroundStyle(.orange)

			HStack {
				ForEach(FontStyle.allCases, id: \.self) { font in
					Button {
						fontStyle = font
					} label: {
						Text("Aa")
							.font(.custom(font.rawValue, size: 10))
					}.buttonStyle(IconButtonStyle())
				}

				Button {
				} label: {
					Image(systemName: "paintpalette.fill")
				}.buttonStyle(IconButtonStyle())

				Button {
					showEditorView.toggle()
					action(
						AnyView(Text(text)
							.font(.custom(fontStyle.rawValue, size: 20))
							.padding()
							.background(
								RoundedRectangle(cornerRadius: 10.0)
									.fill(backgroundColor)
							)
)					)
				} label: {
					Text("Finish")
				}.buttonStyle(SmallPrimaryButtonStyle())
			}

			ColorPicker("Select background", selection: $backgroundColor)
		}
	}

	enum FontStyle: String, CaseIterable {
		case academyEngraved = "Academy Engraved LET"
		case chalkBoard = "Chalkboard SE"
		case herculanum = "Herculanum"
	}
}

extension TextEditorView {
}

//#Preview {
//	TextEditorView(showEditorView: .constant(true))
//}
