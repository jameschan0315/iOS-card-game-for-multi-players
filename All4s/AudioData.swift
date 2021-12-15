//
//  PublicData.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/4/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation
import AVFoundation

final class AudioData {
	static let sharedInstance = AudioData()
	let userDefaults = UserDefaults.standard
	
	let selfTest = false
	
	var playCardSounds = [AVAudioPlayer?]()
	var shuffleSound : AVAudioPlayer?
	var dealSound : AVAudioPlayer?
	var flipSound : AVAudioPlayer?
	
	init() {
		setupAudioFiles()
	}

	func setupAudioFiles() {
		for i in 1...8 {
			self.playCardSounds.append(setupAudioPlayerWithFile("play\(i)" as NSString, type:"mp3"))
		}
		self.dealSound = setupAudioPlayerWithFile("shuffle", type:"mp3")
		self.shuffleSound = setupAudioPlayerWithFile("shuffle2", type:"mp3")
		self.flipSound = setupAudioPlayerWithFile("flip", type:"mp3")
	}
	
	func playSound(_ sound: AVAudioPlayer?) {
		guard let status = userDefaults.value(forKey: "sound") as? Bool else {return}
		if !status {return}
		sound?.stop()
		sound?.currentTime = 0
		sound?.play()
	}
	func playCardSound() {
		playSound(playCardSounds[Int.rand(8)])
	}
	func playKickSound() {
		playSound(flipSound)
	}

	func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer?  {
		var audioPlayer:AVAudioPlayer?
		if let path = Bundle.main.path(forResource: file as String, ofType: type as String) {
			let url = URL(fileURLWithPath: path)
			do {try audioPlayer = AVAudioPlayer(contentsOf: url)}
			catch {print("Player not available")}
		}
		return audioPlayer
	}
	
}
