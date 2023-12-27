//
//  StreamManager.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/25.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import WebRTC
import OSLog

enum FBCandidateType {
	case offerCandidates
	case answerCandidates
}

final class StreamService: StreamServiceProvider {
	var delegate: StreamServiceProviderDelegate?

	static let shared = StreamService()

	private let streamCollection = Firestore.firestore().collection("streams")

	private func getAnswerCandidateCollection(_ id: String) -> CollectionReference {
		streamCollection.document(id).collection("answerCandidates")
	}

	private func getOfferCandidateCollection(_ id: String) -> CollectionReference {
		streamCollection.document(id).collection("offerCandidates")
	}

	private let encoder = JSONEncoder()
	private let decoder = JSONDecoder()

	private init() { }

	public func getStreamOffer(id: String) async throws -> RTCSessionDescription? {
		let streamDict = try await streamCollection.document(id).getDocument().data()
		if let data = streamDict?["offer"] as? Data {
			let message = try JSONDecoder().decode(Message.self, from: data)

			switch message {
			case .sdp(let sessionDescription): return sessionDescription.rtcSessionDescription
			default: return nil
			}
		}
		return nil
	}

	// create stream doc
	public func createStream(data: Data) async throws -> String {
		let streamDoc = streamCollection.document()
		try await streamDoc.setData(["offer": data])
		let offerCandidateCollection = getOfferCandidateCollection(streamDoc.documentID)
		let answerCandidateCollection = getAnswerCandidateCollection(streamDoc.documentID)
		do {
			streamDoc.addSnapshotListener { snapshot, error in
				if let data = snapshot?.data() {
					if let answerData = data["answer"] as? Data {
						self.delegate?.streamService(self, didReceiveData: answerData)
					}
//					logger.info("\(offerCandidateRef?.documentID)")
				}
			}

			answerCandidateCollection.addSnapshotListener { snapshot, error in
				if let snapshot = snapshot {
					snapshot.documentChanges.forEach { diff in
						if diff.type == .added {
							do {
//								let data = try diff.document.data(as: FBOfferCandidate.self)
//								let data = diff.document.
								let dataDict = diff.document.data()
								guard let data = dataDict["data"] as? Data else { return }
 								self.delegate?.streamService(self, didReceiveData: data)
							} catch {
								logger.error("something wrong with the answerCandidates")
							}
						}
					}
				}
			}
		} catch {
			logger.error("signalling failed")
			debugPrint(error.localizedDescription)
		}
		
		return streamDoc.documentID
	}

	public func getAllStreamIds(completionHandler: @escaping (String) -> ()) {
		streamCollection.addSnapshotListener { snapshot, error in
			if let snapshot = snapshot {
				snapshot.documentChanges.forEach { diff in
					if diff.type == .added {
						let id = diff.document.documentID
						completionHandler(id)
					}
				}
			}
		}
	}

	public func joinStream(
		streamId: String,
		data: Data
	) async throws
	{
		let streamDoc = streamCollection.document(streamId)
		let answerCandidatesCollection = getAnswerCandidateCollection(streamId)
		let offerCandidatesCollection = getOfferCandidateCollection(streamId)

		try await streamDoc.updateData(["answer": data])

		offerCandidatesCollection.addSnapshotListener { snapshot, error in
			snapshot?.documentChanges.forEach { diff in
				if diff.type == .added {
					let dataDict = diff.document.data()
					guard let data = dataDict["data"] as? Data else { return }

					self.delegate?.streamService(self, didReceiveData: data)
				}
			}
		}
	}

	public func saveCandidate(streamId: String, type: FBCandidateType, data: Data) async throws {
		let collection: CollectionReference
		switch type {
		case .offerCandidates: collection = getOfferCandidateCollection(streamId)
		case .answerCandidates: collection = getAnswerCandidateCollection(streamId)
		}

		try await collection.addDocument(data: ["data": data])
	}

	public func closeStream(id: String) {
		let streamDoc = streamCollection.document(id)

		let answerCollection = getAnswerCandidateCollection(id)
		let offerCollection = getOfferCandidateCollection(id)
		
		answerCollection.getDocuments { snapshot, error in
			snapshot?.documents.forEach { doc in
				answerCollection.document(doc.documentID).delete()
			}
		}

		offerCollection.getDocuments { snapshot, error in
			snapshot?.documents.forEach { doc in
				offerCollection.document(doc.documentID).delete()
			}
		}

		streamDoc.delete()
	}
}

fileprivate let logger = Logger(subsystem: "ios22-jason.FlavorFlash", category: "StreamManager")
