//
//  Binding+EXT.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/9.
//

import SwiftUI

extension Binding {
	func unwrapped<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
		let binding = Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
		return binding
	}
}
