//
//  Speeches.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 3/17/17.
//  Copyright © 2017 GB Soft. All rights reserved.

import Foundation

final class SpeechData {
	static let sharedInstance = SpeechData()
	
	private init() {}

	let standSpeech: [String] = [
		"Good to go!",
		"Stand",
		"Lehwe play!",
		"Come out allyuh hole!",
		"Nice!",
		"Ah ready fuh allyuh!",
		"Yuh eh ha nuttn wid me",
		"Boom!",
		"I iz Boss!",
		"Handle Dis!",
        "Wha iz my name!",
        "Allyuh eh make me out awa!",
        "Handle allyuh stories!",
        "Hahaaaaa!",
	]
	let begSpeech: [String] = [
		"Ah beg",
        "Doh make mih beg",
        "Like God fuhgeh me",
		"Gimme one",
		"Run it",
		"Tings bad here",
		"Do yuh ting nuh",
		"Come come",
		"Wha kina han iz dis!",
		"Geez an' Ages!",
		"Put yuh money whey yuh mout iz",
		"Bring ting",
	]
	let takeOneSpeech: [String] = [
		"Steups",
		"Take one",
        "Too bad",
        "Well look ting",
        "Handle yuh stories",
		"You eh runnin me!",
		"Enjoy yuh point",
		"Play yuh cyard!",
		"Play!!",
		"Hahahah",
		"Yuh winnin!",
		"Yuh madawa",
		"Like you eh make me out!",
        "What a ting...",
	]
	let redealSpeech: [String] = [
		"Whew!",
		"Tanx Eh!",
		"Mih lucky day",
		"Yes sir!",
		"Papa God",
		"Tort yuh wud never ask",
		"Beex DA pothole!",
		"Yuh take long enough!",
		"No problem",
		"I eh arguin wid dat!",
		"Dis eh right",
	]
	
	//========================= Speech Functions ===========================
	func getStandSpeech() -> String {
		return SpeechData.sharedInstance.standSpeech[Int.rand(SpeechData.sharedInstance.standSpeech.count)]
	}
	
	func getBegSpeech() -> String {
		return SpeechData.sharedInstance.begSpeech[Int.rand(SpeechData.sharedInstance.begSpeech.count)]
	}
	
	func getTakeOneSpeech() -> String {
		return SpeechData.sharedInstance.takeOneSpeech[Int.rand(SpeechData.sharedInstance.takeOneSpeech.count)]
	}
	
	func getRedealSpeech() -> String {
		return SpeechData.sharedInstance.redealSpeech[Int.rand(SpeechData.sharedInstance.redealSpeech.count)]
	}
}
