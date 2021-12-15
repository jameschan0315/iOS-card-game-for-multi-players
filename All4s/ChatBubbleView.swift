//
//  ChatBubble.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/22/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import UIKit

class ChatBubbleView: UIView {
	let delay = 0.5
//	let delay = PublicData.sharedInstance!.delay

	let X: CGFloat
	let Y: CGFloat
	let pos: Int
	let paddingX: CGFloat = 10.0
	let paddingY: CGFloat = 0
	var imageViewBG: UIImageView?
	var chatMessageView: UITextView!
//	var chatMessageView: UILabel!
	var bubbleImageFileName = ""

	init(X: CGFloat, Y: CGFloat, pos: Int){
		self.X = X
		self.Y = Y
		self.pos = pos
		super.init(frame: CGRect(x: X, y: Y, width: 0, height: 0))
		self.backgroundColor = UIColor.clear
		
		// frame calculation
		chatMessageView = UITextView(frame: CGRect(x: paddingX, y: paddingY, width: 0 ,height: 0))
//		chatMessageView = UILabel(frame: CGRectMake(paddingX, paddingY, 0 ,0))
		chatMessageView.backgroundColor = UIColor.clear
		chatMessageView.textColor = UIColor.black
		
		switch(pos) {
		case 0:
			chatMessageView.textAlignment = .center
			chatMessageView.frame.origin.x = paddingX*2
		case 1: chatMessageView.textAlignment = .right
		case 2:
			chatMessageView.textAlignment = .center
			chatMessageView.frame.origin.x = paddingX*2
		case 3:
			chatMessageView.textAlignment = .left
			chatMessageView.frame.origin.x = paddingX*2
		default: break
		}
		self.addSubview(chatMessageView)
	}
	
	func addText(_ text: String) {
		chatMessageView.font = UIFont.systemFont(ofSize: 14)
        chatMessageView.text = text
		chatMessageView.sizeToFit() // Getting fullsize of it
		
		// Calculate new width and height of the chat bubble view
		let viewHeight = chatMessageView.frame.maxY + paddingY
		let viewWidth = chatMessageView.frame.width + paddingX
		
		// Add new width and height of the chat bubble frame
		self.frame = CGRect(x: X, y: Y, width: viewWidth + paddingX, height: viewHeight + paddingY)
		
		// Add the resizable image view to give it bubble like shape
		imageViewBG = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height))
		
		switch (pos) {
		case 0:
			bubbleImageFileName = "bubbleGreyWest"
			imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 14, left: 22, bottom: 17, right: 20))
		case 1:
			bubbleImageFileName = "bubbleGreyEast"
			imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 14, left: 14, bottom: 17, right: 28))
		case 2:
			bubbleImageFileName = "bubbleGreyWest"
			imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 14, left: 22, bottom: 17, right: 20))
		case 3:
			bubbleImageFileName = "bubbleGreyWest"
			imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 14, left: 22, bottom: 17, right: 20))
		default: break
		}
		
		self.addSubview(imageViewBG!)
		self.sendSubviewToBack(imageViewBG!)
		
		// Frame recalculation for filling up the bubble with background bubble image
		let repositionXFactor:CGFloat = 0
		let bgImageNewX = imageViewBG!.frame.minX + repositionXFactor
		let bgImageNewWidth =  imageViewBG!.frame.width + CGFloat(12.0)
		let bgImageNewHeight =  imageViewBG!.frame.height + CGFloat(6.0)
		
		// Need to maintain the minimum right side padding from the right edge of the screen
		imageViewBG?.frame = CGRect(x: bgImageNewX, y: 0.0, width: bgImageNewWidth, height: bgImageNewHeight)
		
		let extra = pos == 1 ? imageViewBG!.frame.width : 0
		self.frame = CGRect(x: X-extra, y: Y, width: frame.width, height: frame.height)
		
	}
	
	// View persistance support
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setTint(_ themeAverage: UIColor) {
		imageViewBG?.image = imageViewBG?.image!.tintWithColor(themeAverage)
	}
	
	func animate(_ delay: Double, cb: @escaping ()->()) {
		animateBubbleIn({() in
			print("in bubble anim cb")
			Int.delay(delay) {
				self.animateBubbleOut({() in
                    cb()
					self.removeFromSuperview()
				})
			}
		})
	}
	
	func animateBubbleIn(_ cb: @escaping ()->()) {
		let scaleTransform = CGAffineTransform(scaleX: 0.0, y: 0.0)
		self.transform = scaleTransform
		UIView.animate(
			withDuration: 0.5,
			delay: 0.0,
			usingSpringWithDamping: 0.4,
			initialSpringVelocity: 0.7,
			options: [UIView.AnimationOptions.curveLinear],
			animations: {
				let scaleTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
				self.transform = scaleTransform
			}, completion: { (finished: Bool) -> Void in
				cb()
		})
	}
	
	func animateBubbleOut(_ cb:@escaping ()->()) {
		UIView.animate(
			withDuration: 0.15,
			delay: 0.0,
			options: UIView.AnimationOptions(),
			animations: {
				let scaleTransform = CGAffineTransform(scaleX: 0.05, y: 0.05)
				self.transform = scaleTransform
			}, completion: { (finished: Bool) -> Void in
				cb()
		})
		
	}

}
