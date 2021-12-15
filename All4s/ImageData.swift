//
//  ImageData.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 1/24/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

final class ImageData {
	static let sharedInstance = ImageData()

	//========================= Image Data ===========================
	let avatars: [String] = [
		"Patricia", "Choc'late", "Bert", "Denzil", "Rasta"
	]
	
	let robotNames: [String] = [
		"Redman", "Balhed", "Slimz", "Tallman", "Dred", "Famalay", "Kaiso", "Hoss", "Hornaman", "Fatboy", "Blackie"
	]

	let backs: [String] = [
		"card1",
		"back1",
		"back2",
		"back3",
		"back4",
		"back5",
		"back6",
	]

	let backgrounds: [String] = [
		"newbackground",
		"maracas1",
		"poui",
		"glass1",
		"glass4",
		"glass5",
		"wood4"
	]

	let faces: [String] = [
		"deck1",
		"deck2",
	]
}
