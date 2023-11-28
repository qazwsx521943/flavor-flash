//
//  SearchBar.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/23.
//

import SwiftUI
import UIKit

struct SearchBar: UIViewRepresentable {
	@Binding var text: String
	var onTextChange: (String) -> Void

	func makeUIView(context: Context) -> some UISearchBar {
		let searchBar = UISearchBar()
		searchBar.delegate = context.coordinator
		searchBar.searchBarStyle = .minimal
		searchBar.autocapitalizationType = .none
		return searchBar
	}

	func updateUIView(_ uiView: UIViewType, context: Context) {
		uiView.text = text
	}

	func makeCoordinator() -> SearchBarCoordinator {
		return SearchBarCoordinator(text: $text, onTextChange: onTextChange)
	}
}

extension SearchBar {
	class SearchBarCoordinator: NSObject, UISearchBarDelegate {
		@Binding var text: String
		var onTextChange: (String) -> Void

		init(text: Binding<String>, onTextChange: @escaping (String) -> Void) {
			_text = text
			self.onTextChange = onTextChange
		}

		func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
			if searchText.isEmpty {
				searchBar.resignFirstResponder()
			}
			text = searchText
			onTextChange(text)
		}
	}
}

//#Preview {
//    SearchBar()
//}
