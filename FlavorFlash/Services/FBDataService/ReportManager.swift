//
//  ReportManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/4.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

final class ReportManager {
	static let shared = ReportManager()

	let reportCollection = Firestore.firestore().collection("reports")

	private init() {}

	func report(id: String, type: ReportType, reason: ReportReason) throws {
		try reportCollection.addDocument(from: FBReport(id: id, type: type, reason: reason))
	}
}
