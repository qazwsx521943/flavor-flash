//
//  SignInAppleHelper.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/11/29.
//

import Foundation
import AuthenticationServices
import CryptoKit

struct SignInWithAppleResult {
	let token: String
	let nonce: String
	let fullName: PersonNameComponents?
}

@MainActor
final class SignInAppleHelper: NSObject {
	typealias SignInWithAppleCompletionHandler = ((Result<SignInWithAppleResult, Error>) -> Void)

	private var currentNonce: String?

	private var completionHandler: SignInWithAppleCompletionHandler?

	// turn completionHandler into async await return values
	func startSignInWithAppleFlow() async throws -> SignInWithAppleResult {
		await withCheckedContinuation { continuation in
			self.startSignInWithAppleFlow { result in
				switch result {
				case .success(let signInAppleResult):
					continuation.resume(returning: signInAppleResult)
					return
				case .failure:
					return
				}
			}
		}
	}

	@MainActor @available(iOS 13, *)
	func startSignInWithAppleFlow(completion: @escaping SignInWithAppleCompletionHandler) {
		guard let topVC = Utilities.shared.topViewController() else {
			completion(.failure(URLError(.badURL)))
			return
		}
		let nonce = randomNonceString()
		currentNonce = nonce
		completionHandler = completion

		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()
		request.requestedScopes = [.fullName, .email]
		request.nonce = sha256(nonce)

		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = topVC
		authorizationController.performRequests()
	}

	private func randomNonceString(length: Int = 32) -> String {
		precondition(length > 0)
		var randomBytes = [UInt8](repeating: 0, count: length)
		let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
		if errorCode != errSecSuccess {
			fatalError(
				"Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
			)
		}

		let charset: [Character] =
		Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

		let nonce = randomBytes.map { byte in
			// Pick a random character from the set, wrapping around if needed.
			charset[Int(byte) % charset.count]
		}

		return String(nonce)
	}

	@available(iOS 13, *)
	private func sha256(_ input: String) -> String {
		let inputData = Data(input.utf8)
		let hashedData = SHA256.hash(data: inputData)
		let hashString = hashedData.compactMap {
			String(format: "%02x", $0)
		}.joined()

		return hashString
	}
}

@available(iOS 13.0, *)
extension SignInAppleHelper: ASAuthorizationControllerDelegate {
	func authorizationController(
		controller: ASAuthorizationController,
		didCompleteWithAuthorization authorization: ASAuthorization) {
		guard
			let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
			let nonce = currentNonce,
			let appleIDToken = appleIDCredential.identityToken,
			let idTokenString = String(data: appleIDToken, encoding: .utf8),
			let displayName = appleIDCredential.fullName
		else {
			completionHandler?(.failure(URLError(.badServerResponse)))
			return
		}

		print("Your full name : \(displayName)")

		let tokens = SignInWithAppleResult(
			token: idTokenString,
			nonce: nonce,
			fullName: appleIDCredential.fullName)

		completionHandler?(.success(tokens))
	}

	func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		// Handle error.
		print("Sign in with Apple errored: \(error)")
		completionHandler?(.failure(URLError(.cannotFindHost)))
	}

}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
	public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		return self.view.window!
	}
}
