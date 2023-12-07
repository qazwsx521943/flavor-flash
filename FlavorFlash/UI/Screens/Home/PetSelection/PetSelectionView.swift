//
//  PetSelectionView.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/7.
//

import SwiftUI

struct Pet: Identifiable {
	let id: String
	let imageName: String
	let speak: String

	static let pets = [
		Pet(id: "1", imageName: "cat_1", speak: "Meow..."),
		Pet(id: "2", imageName: "cat_2", speak: "不想上班..."),
		Pet(id: "3", imageName: "cat_3", speak: "QQ..."),
	]
}

struct PetSelectionView: View {
	@Binding var currentSelectedSkin: BoxSkin?

	var action: ((BoxSkin) -> Void)?

	var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				ForEach(Pet.pets) { pet in
					PetSelectionCell(pet: pet, isCurrentSelection: isCurrentSelectedSkin(pet))
						.onTapGesture {
							action?(BoxSkin(rawValue: pet.imageName)!)
						}
				}
			}
		}
		.background(
			.black.opacity(0.8)
		)
	}


	private func isCurrentSelectedSkin(_ pet: Pet) -> Bool {
		guard let currentSelectedSkin else { return false }

		return currentSelectedSkin.rawValue == pet.imageName
	}
}

struct PetSelectionCell: View {
	let pet: Pet

	var isCurrentSelection: Bool

	var body: some View {
			HStack(alignment: .center) {
				Image(pet.imageName)
					.resizable()
					.scaledToFit()
					.frame(width: 100)
					.lightWeightShadow()
					.overlay(alignment: .bottomTrailing) {
						if isCurrentSelection {
							Image(systemName: "checkmark.circle")
								.foregroundStyle(.green)
						}
					}

				Text(pet.speak)
					.captionStyle()
			}
			.frame(height: 150)
	}
}

#Preview {
	Group {
		PetSelectionView(currentSelectedSkin: .constant(BoxSkin.cat01))

		PetSelectionCell(pet: Pet.pets.first!, isCurrentSelection: true)
	}
}
