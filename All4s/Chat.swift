//
//  Chat.swift
//  All4s
//
//  Created by Adrian Bartholomew2 on 3/31/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

import UIKit


extension RootViewController {
	
	func addAvatarTapRecognizer() {
		let singleTap = UITapGestureRecognizer(target: self, action: #selector(showChat(_:)))
		singleTap.delegate = self
		singleTap.numberOfTapsRequired = 1
		singleTap.numberOfTouchesRequired = 1
		avatar0View.isUserInteractionEnabled = true
		
		avatar0View.addGestureRecognizer(singleTap)
	}

	@objc func showChat(_ sender: UITapGestureRecognizer) {
		showChatView()
	}
	
	func showChatView() {
		chatView.isHidden = !chatView.isHidden
		originChatInputTextField.text = ""
	}
	
	func hideChatView() {
		chatView.isHidden = true
	}
	
	func showChatMessage(_ message: String) {
		if message.trim().length == 0 {return animateCloseChat()}
		showBubble(message, pos: 0, delay:5, cb: {})
		originChatInputTextField?.text = ""
        originChatInputTextField?.resignFirstResponder()
        originChatInputTextView?.text = ""
        originChatInputTextView?.resignFirstResponder()
		animateCloseChat()
	}
	
	func animateCloseChat() {
		let duration: Double = 0.3
		UIView.animate(withDuration: duration,
			delay: 0,
			options: UIView.AnimationOptions(),
			animations: {
				self.chatView.alpha = 0
			}, completion: { (finished: Bool) -> Void in
				self.chatView.isHidden = true
				self.chatView.alpha = 1
		})
	}
}
