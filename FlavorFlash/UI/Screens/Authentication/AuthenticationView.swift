//
//  AuthenticationView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/19.
//

import SwiftUI

struct AuthenticationView: View {
	var body: some View {
		VStack {
			NavigationLink {
				EmailSignInView()
			} label: {
				Text("Sign in with Email")
					.font(.headline)
					.background(.black)
					.foregroundStyle(.white)
					.frame(height: 100)
					.frame(minWidth: 200)
					.cornerRadius(10)
			}
		}
		.navigationTitle("Sign In")
	}
}

#Preview {
	NavigationStack {
		AuthenticationView()
	}
}
