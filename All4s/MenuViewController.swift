//
//  PreferencesViewController.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/21/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import UIKit
import MessageUI

class MenuViewController: UITableViewController, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {

	let userDefaults = UserDefaults.standard
	weak var delegate: SettingsDelegate?
    weak var avatarDelegate: AvatarDelegate?
	let imageData = ImageData.sharedInstance

	var backIndex: Int!
	var avatarIndex: Int!
	var backgroundIndex: Int!
	var facesIndex: Int!
	
	@IBAction func done(_ sender: UIBarButtonItem) {
		done()
	}
	@IBOutlet weak var backView: UIImageView!
	@IBOutlet weak var avatarView: UIImageView!
	@IBOutlet weak var backgroundView: UIImageView!
	@IBOutlet weak var facesView: UIImageView!
	
	@IBOutlet weak var matchesSwitch: UISwitch!
	@IBAction func matches(_ sender: UISwitch) {
		userDefaults.set(sender.isOn, forKey: "matches")
		delegate?.setMatches(sender.isOn)
	}
	@IBOutlet weak var soundSwitch: UISwitch!
	@IBAction func sound(_ sender: UISwitch) {
		delegate?.setSound(sender.isOn)
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		initSettings()
	}
	
	func initSettings() {
		if let sound = userDefaults.object(forKey: "sound") as? Bool {
			soundSwitch.isOn = sound
		} else {soundSwitch.isOn = false}
		if let matches = userDefaults.object(forKey: "matches") as? Bool {
			matchesSwitch.isOn = matches
		} else {matchesSwitch.isOn = false}
		if let backIndex = userDefaults.value(forKey: "backView") as? Int {
			self.backIndex = backIndex
		} else {self.backIndex = 0}
		if let backgroundIndex = userDefaults.value(forKey: "backgroundView") as? Int {
			self.backgroundIndex = backgroundIndex > imageData.backgrounds.count - 1 ? 0 : backgroundIndex
		} else {self.backgroundIndex = 0}
		if let avatarIndex = userDefaults.value(forKey: "avatarView") as? Int {
			self.avatarIndex = avatarIndex
		} else {self.avatarIndex = 0}
		if let facesIndex = userDefaults.value(forKey: "facesView") as? Int {
			self.facesIndex = facesIndex
		} else {self.facesIndex = 0}
		backView.image = UIImage(named: imageData.backs[backIndex])
		avatarView.image = UIImage(named: imageData.avatars[avatarIndex])
		backgroundView.image = UIImage(named: imageData.backgrounds[backgroundIndex])
		facesView.image = UIImage(named: imageData.faces[facesIndex] + "-card49")
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch(indexPath.section) {
		case 1:
			switch (indexPath.row) {
			case 0:
				backIndex = (backIndex+1)%imageData.backs.count
				backView.image = UIImage(named: imageData.backs[backIndex])
				userDefaults.set(backIndex, forKey: "backView")
				delegate?.setCardsBack(backView.image!)
			case 1:
				avatarIndex = (avatarIndex+1)%imageData.avatars.count
				avatarView.image = UIImage(named: imageData.avatars[avatarIndex])
				userDefaults.set(avatarIndex, forKey: "avatarView")
				delegate?.setAvatar(avatarIndex, pos:0)
                avatarDelegate?.setAvatar(avatarIndex, pos:0)
			case 2:
				backgroundIndex = (backgroundIndex+1)%imageData.backgrounds.count
				backgroundView.image = UIImage(named: imageData.backgrounds[backgroundIndex])
				userDefaults.set(backgroundIndex, forKey: "backgroundView")
				delegate?.setBackground(backgroundView.image!)
			case 3:
				facesIndex = (facesIndex+1)%imageData.faces.count
				facesView.image = UIImage(named: imageData.faces[facesIndex] + "-card49")
				userDefaults.set(facesIndex, forKey: "facesView")
				delegate?.setFaces(imageData.faces[facesIndex])
			default: break
			}
		case 2:
			sendEmail()
		default: break
		}
	}
	
	func sendEmail() {
		if MFMailComposeViewController.canSendMail() {
			let mail = MFMailComposeViewController()
			mail.mailComposeDelegate = self
			mail.setToRecipients(["adrian@bartholomusic.com"])
			mail.setMessageBody("Write your text here . . .", isHTML: false)
			mail.setSubject("Message from All4s")
			
			self.present(mail, animated: true, completion: nil)
		} else {
			print("this device cannot send email")
		}
	}
	
	
	// MFMailComposeViewControllerDelegate
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		switch result.rawValue {
		case MFMailComposeResult.sent.rawValue:
			print("Email Sent")
		case MFMailComposeResult.saved.rawValue:
			print("Email Saved")
		case MFMailComposeResult.cancelled.rawValue:
			print("Email Cancelled")
		case MFMailComposeResult.failed.rawValue:
			print("Email Error: \(String(describing: error?.localizedDescription))")
		default:
			break
		}
		controller.dismiss(animated: true, completion: nil)
	}
	
	func done() {
		self.dismiss(animated: true, completion: nil)
	}
}
