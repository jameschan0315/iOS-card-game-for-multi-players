//
//  AvatarView.swift
//  War
//
//  Created by Adrian Bartholomew2 on 2/11/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import UIKit
import AVFoundation

class AvatarView {
	let imageData = ImageData.sharedInstance
	
	let index: Int
	let pos: Int
	var avatarView: UIImageView
	var blinkOn = true
	
	let name: String
	var images = [UIImage?]()

	init(index: Int, pos: Int, view: UIImageView) {
		self.index = index
		self.pos = pos
		self.avatarView = view
		self.name = index == -1 ? "Tinmathy" : imageData.avatars[index]
		setImages()
		start()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func setImages() {
		for i in 3 {
			let calName = i > 0
				? name + (String)(i)
				: name
			images.append(UIImage(named: calName))
		}
	}
	
	func start() {
		if let _ = images[1] {
			blink()
		} else {
			avatarView.image = UIImage(named: name)
		}
	}
	
	func stop() {
		self.blinkOn = false
	}
	
	func blink( _ state: Int = 0) {
		let st = state % 3
		let dly: Double!
		switch(st) {
		case 0: dly = 4.0 + (Double)(rand(70)) / 10
		case 1: dly = 0.25
		case 2: dly = 0.15
		default: dly = 2.0
		}
		self.avatarView.image = images[st]
		delay(dly) { [weak self] in
			guard let strongSelf = self else {return}
//			print("blink", dly)
			if strongSelf.blinkOn {
				strongSelf.blink(st+1)
			}
		}
	}
	
	func delay(_ delay:Double, weak closure:@escaping ()->()) {
		DispatchQueue.main.asyncAfter(
			deadline: DispatchTime.now() + delay, execute: closure
		)
	}
	
	func rand(_ num: Int) -> Int {
		return Int(arc4random_uniform(UInt32(num)))
	}
	
}
