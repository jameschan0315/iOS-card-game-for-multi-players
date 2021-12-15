//
//  ViewController.swift
//  AllFours
//
//  Created by Adrian Bartholomew on 12/26/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

protocol SettingsDelegate: class {
	func setSound(_ sound: Bool)
	func setMatches(_ matches: Bool)
	func setCardsBack(_ image: UIImage)
    func setAvatar(_ index: Int, pos: Int)
	func setBackground(_ image: UIImage)
	func setFaces(_ facesName: String)
}

protocol Animatable: class {
    func animateThirdPartyPlayCard(pos: Int, cardIndex: Int, sourcePos: Int?)
}

class RootViewController: UIViewController, SettingsDelegate, Animatable, UITextViewDelegate, UIGestureRecognizerDelegate {
	
	
	
	var appDelegate: AppDelegate!

    var GameRef: DocumentReference!
    var RoomId: String!
    var UID: String!
    var OWNER: Bool!
	var gameViewModel: GameViewModel?
	var handViewModel: HandViewModel?
    
    var docSeatsRef: DocumentReference!
//    var authListener: AuthStateDidChangeListenerHandle!

/*========================= VIEWS =========================*/
	var alertView: UIView!
	var back = UIImage(named: "card1")! {
		didSet {addCardBack(kickView)}
	}
	var tableCardViews = [UIImageView]()
	var avatarImageViews = [UIImageView]()
	var seatImageButtons = [UIButton]()
	var seatLabels = [UILabel]()
	var avatarViews: [AvatarView?] = [nil, nil, nil, nil]
	
    @IBOutlet weak var startWait: UILabel!
    
	@IBOutlet var world: UIView!
	@IBOutlet weak var backgroundImageView: UIImageView!
	//--------------- Board Views --------------------
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var startBtn: UIBarButtonItem!
	@IBOutlet weak var startNowBtn: UIButton!
	@IBOutlet weak var soundIcon: UIBarButtonItem!
	@IBOutlet weak var bottomSectionView: UIView!
	
	@IBOutlet weak var seat0Button: UIButton!
	@IBOutlet weak var seat1Button: UIButton!
	@IBOutlet weak var seat2Button: UIButton!
	@IBOutlet weak var seat3Button: UIButton!
	
	@IBOutlet weak var avatar3View: UIImageView!
	@IBOutlet weak var avatar2View: UIImageView!
	@IBOutlet weak var avatar1View: UIImageView!
	@IBOutlet weak var avatar0View: UIImageView!
	
	//--------------- Card Views --------------------
	@IBOutlet weak var cardSouthView: UIImageView!
	@IBOutlet weak var cardEastView: UIImageView!
	@IBOutlet weak var cardNorthView: UIImageView!
	@IBOutlet weak var cardWestView: UIImageView!
	@IBOutlet weak var kickView: UIImageView!
	@IBOutlet weak var kickLabel: UILabel!
	
	//--------------- Username Views --------------------
	@IBOutlet weak var username0: UILabel!
	@IBOutlet weak var username1: UILabel!
	@IBOutlet weak var username2: UILabel!
	@IBOutlet weak var username3: UILabel!
	
	//--------------- Score Views --------------------
	@IBOutlet weak var gamePoints1: UILabel!
	@IBOutlet weak var gamePoints0: UILabel!
	@IBOutlet weak var score0: UILabel!
	@IBOutlet weak var score1: UILabel!
	@IBOutlet weak var matchesStack0: UIView!
	@IBOutlet weak var matchesStack1: UIView!
	
	//--------------- Modal Views --------------------
	@IBOutlet weak var modalView: UIView!
	@IBOutlet weak var lostStackView: UIStackView!
	@IBOutlet weak var wonStackView: UIStackView!
	@IBOutlet weak var beggarOptionsStackView: UIStackView!
	@IBOutlet weak var dealerOptionsStackView: UIStackView!
	@IBOutlet weak var scoreNamesStackView: UIStackView!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
	
	@IBOutlet weak var infoStackLabel: UILabel!
	@IBOutlet weak var weHighLabel: UILabel!
	@IBOutlet weak var weLowLabel: UILabel!
	@IBOutlet weak var weJackLabel: UILabel!
	@IBOutlet weak var weHangJackLabel: UILabel!
	@IBOutlet weak var weGameLabel: UILabel!
	
	@IBOutlet weak var demHighLabel: UILabel!
	@IBOutlet weak var demLowLabel: UILabel!
	@IBOutlet weak var demJackLabel: UILabel!
	@IBOutlet weak var demHangJackLabel: UILabel!
	@IBOutlet weak var demGameLabel: UILabel!

	//--------------- Chat View --------------------
	@IBOutlet weak var chatView: UIView!
	@IBOutlet weak var originChatInputTextField: UITextField!
    @IBOutlet weak var originChatInputTextView: UITextView!
/*========================= END VIEWS =========================*/
	
	
/*========================= ACTIONS =========================*/
	
	//--------------- Chat View --------------------
	@IBAction func sendChat(_ sender: UIButton) {
        if originChatInputTextView != nil && !originChatInputTextView.isHidden {
            showChatMessage(originChatInputTextView.text!)
        }
        else {
            showChatMessage(originChatInputTextField.text!)
        }
	}
	//--------------- End Chat View --------------------
	
	//--------------- Seat Views --------------------
	@IBAction func sit0(_ sender: UIButton) {
		chooseSeat(0, sender: sender)
	}
	@IBAction func sit1(_ sender: UIButton) {
		chooseSeat(1, sender: sender)
	}
	@IBAction func sit2(_ sender: UIButton) {
		chooseSeat(2, sender: sender)
	}
	@IBAction func sit3(_ sender: UIButton) {
		chooseSeat(3, sender: sender)
	}
	//--------------- End Seat Views --------------------
	
	//--------------- Button Actions -------------------
	@IBAction func begButton(_ sender: UIButton) {
		hideModalViews()
		gameViewModel?.userGameStateChoice(.beg)
	}
	@IBAction func standButton(_ sender: UIButton) {
		hideModalViews()
		gameViewModel?.userGameStateChoice(.stand)
	}
	@IBAction func takeOneButton(_ sender: UIButton) {
		hideModalViews()
		gameViewModel?.userGameStateChoice(.take_ONE)
	}
	@IBAction func redealButton(_ sender: UIButton) {
		hideModalViews()
		gameViewModel?.userGameStateChoice(.redeal)
	}
	
	@IBAction func start(_ sender: UIBarButtonItem) {
        newGame()
	}
	@IBAction func startNow(_ sender: UIButton) {
        if (sender.titleLabel?.text == "START") {
            startGame()
        } else {
            continueGame()
        }
	}
	@IBAction func wonStartBtn(_ sender: UIButton) {
		startGame()
	}
	@IBAction func lostStartBtn(_ sender: UIButton) {
		startGame()
	}
	@IBAction func sound(_ sender: UIBarButtonItem) {
		toggleSound()
	}
/*========================= END ACTIONS =========================*/
	
/*========================= PROPERTIES =========================*/
	let audioData = AudioData.sharedInstance
	let imageData = ImageData.sharedInstance
	let speechData = SpeechData.sharedInstance
	
    let userDefaults = UserDefaults.standard
	
    let cardWidth: CGFloat = 90
    let cardHeight: CGFloat = 125
	let cardDim: (CGFloat, CGFloat) = (72, 100)
	var hVC: HandViewController?
    var themeAverage = UIColor() {
        didSet {
            startNowBtn.backgroundColor = themeAverage
            modalView.backgroundColor = themeAverage
        }
    }
	
	var alreadyInitialized = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
	}
	
	//============================= MAIN!!! ================================
    
    override func viewDidLoad() {
		super.viewDidLoad()
		
		#if Free
			print("Free version")
		#else
			print("Paid Version")
		#endif
		
		DispatchQueue.main.async {
            self.world.isHidden = false
            self.tableView.isHidden = false
			self.initSettings()
            // In the UI because the game model isn't yet created
            self.addSeatUpdatesCollection()
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "SettingsModal" {
			let destination = segue.destination as! UINavigationController
			let target = destination.topViewController as! MenuViewController
			target.delegate = self
            target.avatarDelegate = gameViewModel
		}
	}
    
    func addSeatUpdatesCollection() {
        guard let GameRef = GameRef else { return }
        let seatData: [String: Any?] = [
            "uid": nil,
            "avatar": nil,
            "pos": nil,
            "username": nil,
        ]
        
        [0,1,2,3].forEach { n in
            if self.OWNER {
                GameRef.collection("seats").document("seat\(n)").setData(seatData as [String : Any]) { err in
                    if let err = err {
                        print("Error creating new seat\(n) doc in Firestore: \(err)")
                    } else {
                        print("Successfully created new seat\(n) doc in Firestore")
                        self.setSeatListener(n)
                    }
                }
            } else {
                self.setSeatListener(n)
            }
        }
    }
    
    var userData = [[String:Any?]]()
    func addToUserData(id: String, avatar: Int, pos: Int, username: String) {
        userData += [["id": id, "avatarIndex": avatar, "pos": pos, "username": username]]
    }

    func deleteFromUserData(_ pos: Int) {
        userData = userData.filter {$0["pos"] as? Int != pos}
    }
    
    func seatOccupied(_ pos: Int) -> Bool {
        return userData.contains(where: {$0["pos"] as? Int == pos})
    }
    
    func setSeatListener(_ index: Int) {
        guard let GameRef = GameRef else { return }
        let ref = GameRef.collection("seats").document("seat\(index)")
        ref.addSnapshotListener { (documentSnapshot, error) in
            print("There was an update to seat\(index)")
            let data = documentSnapshot?.data()
            if let id = data?["uid"] as? String {
                let pos = data!["pos"] as! Int
                let avatar = data!["avatar"] as? Int ?? 0
                let username = data!["username"] as? String ?? ""
                self.addToUserData(id: id, avatar: avatar, pos: pos, username: username)
                if self.gameViewModel == nil {
                    self.processDisplayUser(avatar, pos: pos, username: username)
                    return
                }
                _ = self.gameViewModel?.createUser([
                    "id" : id,
                    "pos": pos,
                    "avatarIndex": avatar,
                    "username": username
                ])
            } else {
                self.gameViewModel?.removeUser(index)
//                self.clearSeat(index)
//                self.deleteFromUserData(index)
            }
        }
    }
    
    func clearSeat(_ index: Int) {
        displayUser(nil, pos: index)
    }
    
    func clearSeats() {
        [0,1,2,3].forEach{clearSeat($0)}
    }
    
    func handViewSetup() {
        handViewModel = HandViewModel()
        gameViewModel?.setHandPlayDelegate = setHandPlayDelegate
        
        hVC = HandViewController(handViewModel!)
        createHandImageView() //TODO: put in HandViewController
        setHandCallback()
    }
    
    func gameViewModelPostSetup() {
        gameViewModel?.appDelegate = appDelegate
        startNowBtn.isEnabled = true
        handViewSetup()
    }
    
    func createGameViewModel(_ seatPos: Int) {
        if gameViewModel != nil {
            print("Error: game already created")
            return
        }
        gameViewModel = GameViewModel(seatPos, gameId: GameRef.documentID, roomId: RoomId!, owner: OWNER)
        gameViewModel?.RoomId = RoomId
        gameViewModel?.addJoinedUsers(userData)
        gameViewModelPostSetup()
        setHandPlayDelegate(gameViewModel)
//        setAvatarDelegate(gameViewModel)
    }
    
    func chooseSeat(_ pos: Int, sender: UIButton) {
        sender.isHidden = true
        startWait.isHidden = OWNER
        startNowBtn.isHidden = !OWNER
        seatImageButtons.forEach({$0.isEnabled = false})
        createGameViewModel(pos)
    }
    
    // TODO: lots of wasted code
    @objc func sit(_ payload: Notification) {
        let userInfo = payload.userInfo!
        let avatarIndex = userInfo["avatarIndex"] as? Int
        let seatPos = userInfo["seatPos"] as! Int
        let username = userInfo["username"] as! String
        displayUser(avatarIndex ?? 0, pos: seatPos, username: username)
    }
    
    func processDisplayUser(_ avatarIndex: Int?, pos: Int, username: String = "") {
        displayUser(avatarIndex, pos: pos, username: username)
//        if gameViewModel == nil || !gameViewModel!.isGameBegun {
//            displayUser(avatarIndex, pos: pos, username: username)
//            return
//        }
//        let relPos = (pos - gameViewModel!.truePlayerPosition + 4) % 4
//        displayUser(avatarIndex, pos: relPos, username: username)
    }
    
    func displayUser(_ avatarIndex: Int?, pos: Int, username: String = "") {
//        startWait.isHidden = OWNER
//        startNowBtn.isHidden = !OWNER
        seatImageButtons.forEach({$0.isEnabled = false})
        avatarImageViews[pos].isHidden = avatarIndex == nil
        seatImageButtons[pos].isHidden = avatarIndex != nil
        seatLabels[pos].text = username
        if avatarIndex == nil { return }
        setAvatar(avatarIndex!, pos: pos)
    }
    
    @objc func displayUser (_ payload: Notification) {
        let userInfo = payload.userInfo!
        let avatarIndex = userInfo["avatarIndex"] as? Int
        let seatPos = userInfo["pos"] as! Int
        let username = userInfo["username"] as! String
        displayUser(avatarIndex ?? 0, pos: seatPos, username: username)
    }
    
    @objc func eraseUser (_ payload: Notification) {
        let userInfo = payload.userInfo!
        let seatPos = userInfo["pos"] as! Int
        clearSeat(seatPos)
    }
    
    @objc func displayRelativeUser (_ payload: Notification) {
        if gameViewModel == nil {
            print ("gameViewModel is nil")
            return
        }
        let userInfo = payload.userInfo!
        let avatarIndex = userInfo["avatarIndex"] as? Int
        var seatPos = userInfo["pos"] as! Int
        let username = userInfo["username"] as! String
        seatPos = (seatPos - gameViewModel!.truePlayerPosition + 4) % 4
        displayUser(avatarIndex ?? 0, pos: seatPos, username: username)
    }
    
    func setAvatar(_ index: Int, pos: Int) {
        avatarViews[pos]?.stop()
        avatarViews[pos] = AvatarView(index:index, pos:pos, view:avatarImageViews[pos])
    }
    @objc func setAvatar(_ payload: Notification) {
        let userInfo = payload.userInfo!
        let index = userInfo["avatarIndex"] as! Int
        let pos = userInfo["pos"] as! Int
        if let tpp =  gameViewModel?.truePlayerPosition {
            let relPos = pos.getRelPos(tpp)
            setAvatar(index, pos: relPos)
        }
    }
    
    ////////  END OF BLOCK /////////
	
	func setHandPlayDelegate(_ delegate: HandPlayDelegate?) {
		handViewModel?.setHandPlayDelegate(delegate)
	}
    
//    func setAvatarDelegate(_ delegate: AvatarDelegate?) {
//        MenuViewController?.avatarDelegate = delegate
//    }
	
	func setHandCallback() {
		guard let updateHandView = hVC?.updateHandView else {return}
		guard let revealHandView = hVC?.revealHandView else {return}
		gameViewModel?.setHandCallback(updateHandView)
		gameViewModel?.handRevealCallback(revealHandView)
		gameViewModel?.vibrateCard = hVC?.vibrateCardView
		hVC?.handViewModel.onCardPlayAnimationComplete = gameViewModel?.onCardPlayAnimationComplete
	}

	func showRobotAvatar(_ pos: Int) {
		avatarImageViews[pos].isHidden = false
	}
	
	func initSettings() {
		NotificationCenter.default.removeObserver(self) // cleanup for new game
		setObservers()
		tableCardViews = [
			cardSouthView, cardEastView, cardNorthView, cardWestView
		]
		
		avatarImageViews = [
			avatar0View, avatar1View, avatar2View, avatar3View
		]
		seatImageButtons = [
			seat0Button, seat1Button, seat2Button, seat3Button
		]
		seatLabels = [
			username0, username1, username2, username3
		]
		initializeCardImageViews()
		
		var backgroundViewIndex = userDefaults.value(forKey: "backgroundView") as? Int
		backgroundViewIndex = backgroundViewIndex == nil ? 0 : backgroundViewIndex
		backgroundViewIndex = backgroundViewIndex! > imageData.backgrounds.count - 1 ? 0 : backgroundViewIndex
		userDefaults.set(backgroundViewIndex!, forKey: "backgroundView")
		let backgroundName = imageData.backgrounds[backgroundViewIndex!]
		backgroundImageView.image = UIImage(named: backgroundName)
		themeAverage = backgroundImageView.image!.areaAverage()
		
		var backViewIndex = userDefaults.value(forKey: "backView") as? Int
		backViewIndex = backViewIndex == nil ? 0 : backViewIndex
		backViewIndex = backViewIndex! > imageData.backs.count - 1 ? 0 : backViewIndex
		userDefaults.set(backViewIndex!, forKey: "backView")
		let backName = imageData.backs[backViewIndex!]
		back = UIImage(named: backName)!
		
		var facesIndex = userDefaults.value(forKey: "facesView") as? Int
		facesIndex = facesIndex == nil ? 0 : facesIndex
		facesIndex = facesIndex! > imageData.faces.count - 1 ? 0 : facesIndex
		userDefaults.set(facesIndex!, forKey: "facesView")
		let facesName = imageData.faces[facesIndex!]
		setFaces(facesName)
		
		var sound = userDefaults.value(forKey: "sound") as? Bool
		sound = sound == nil ? true : sound
		setSound(sound!)
		
		var matches = userDefaults.value(forKey: "matches") as? Bool
		matches = matches == nil ? true : matches
		setMatches(matches!)
		
		initializeStartNowButton()

		addAvatarTapRecognizer()
		addKickTapRecognizer()
	}
	
	func setSound(_ sound: Bool) {
		soundIcon.image = sound ? UIImage(named: "audio-on") : UIImage(named: "audio-mute")
		userDefaults.set(sound, forKey: "sound")
	}
	
	func setMatches(_ matches: Bool) {
		matchesStack0.isHidden = !matches
		matchesStack1.isHidden = !matches
		score0.isHidden = matches
		score1.isHidden = matches
		userDefaults.set(matches, forKey: "matches")
	}
	func setCardsBack(_ back: UIImage) {
		hVC?.back = back
		self.back = back
	}
	
	func setFaces(_ facesName: String) {
		// set faces of all cards in hand and on table
		hVC?.switchCardFaces(facesName)
		switchCardFaces(facesName)
	}
	
	func setBackground(_ image: UIImage) {
		backgroundImageView.image = image
		themeAverage = image.areaAverage()
//        initializeStartNowButton()
	}

    @objc func playStand(_ sourcePos: Int) {
		hideModalViews()
		gameViewModel?.playStandComplete(sourcePos)
	}
	/*===================== END OF SETTINGS ===============================================*/
	
	func newGame() {
		present(createAlertController(), animated: true, completion: nil)
	}

	
	func createAlertController() -> UIAlertController {
		let alertController = UIAlertController(title: "Welcome To Trinidad AllFours!", message:
			"Start a new game?", preferredStyle: UIAlertController.Style.alert)
		alertController.addAction(UIAlertAction(title: "Nah", style: UIAlertAction.Style.cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Mmhm", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) in
            self.startGame()
		}))
		return alertController
	}
	//----------------------------
	
	func toggleSound() {
		if let sound = userDefaults.value(forKey: "sound") as? Bool {
			userDefaults.set(!sound, forKey: "sound")
			setSound(!sound)
		} else {
			userDefaults.set(true, forKey: "sound")
			setSound(true)
		}
	}
	
	@objc func newGame(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {newGame()}
	}
	
	func startGame(_ doInit: Bool = true) {
        if gameViewModel?.GameId == nil {return}
        guard let users = gameViewModel?.game?.users else {return}
        print("start game")
        startNowBtn.isHidden = true
        startWait.isHidden = true
        clearAll()
        if users.count == 0 {
            if doInit {initSettings()}
            rotateTable()
        } else {
            gameViewModel?.startGame()
        }
	}
    
    func continueGame() {
        if gameViewModel?.GameId == nil {return}
        print("continue game")
        startNowBtn.isHidden = true
        startWait.isHidden = true
        gameViewModel?.continueGame()
    }
    
    @objc func rotateTable(_ payload: Notification) {
        if gameViewModel!.isOwner() {return}
        startWait.isHidden = true
//        rotateTable()
    }
    
    func rotateTable() {
        if let truePos = gameViewModel?.truePlayerPosition {
            animateTableRotation(Double(truePos)) {
                if !self.gameViewModel!.isOwner() {return}
                self.gameViewModel?.setupGame()
                self.gameViewModel?.startGame()
            }
        } else {print("truePlayerPosition is nil")}
    }
    
    func animateTableRotation(_ truePos: Double, complete: @escaping ()->Void) {
        if truePos == 0 {
            complete()
            return
        }
        CATransaction.begin()
        
        let rotateAnimation = CASpringAnimation(keyPath: "transform.rotation.z")
        //--------------- Stop from reverting on completion
//        rotateAnimation.fillMode = kCAFillModeForwards;
//        rotateAnimation.isRemovedOnCompletion = false;
        //---------------
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi / 2 * truePos)
        rotateAnimation.duration = 1.5
        rotateAnimation.mass = 2.0
        rotateAnimation.stiffness = 80
        rotateAnimation.damping = 30
        
        // Callback function
        CATransaction.setCompletionBlock {
            self.drawRelativeTable()
            complete()
        }
        
        tableView.layer.add(rotateAnimation, forKey: nil)
        
        rotateAnimation.toValue = rotateAnimation.toValue as! Double * -1.0
        tableCardViews[0].layer.add(rotateAnimation, forKey: nil)
        tableCardViews[1].layer.add(rotateAnimation, forKey: nil)
        tableCardViews[2].layer.add(rotateAnimation, forKey: nil)
        tableCardViews[3].layer.add(rotateAnimation, forKey: nil)
        avatarImageViews[0].layer.add(rotateAnimation, forKey: nil)
        avatarImageViews[1].layer.add(rotateAnimation, forKey: nil)
        avatarImageViews[2].layer.add(rotateAnimation, forKey: nil)
        avatarImageViews[3].layer.add(rotateAnimation, forKey: nil)
        seatImageButtons[0].layer.add(rotateAnimation, forKey: nil)
        seatImageButtons[1].layer.add(rotateAnimation, forKey: nil)
        seatImageButtons[2].layer.add(rotateAnimation, forKey: nil)
        seatImageButtons[3].layer.add(rotateAnimation, forKey: nil)
        seatLabels[0].layer.add(rotateAnimation, forKey: nil)
        seatLabels[1].layer.add(rotateAnimation, forKey: nil)
        seatLabels[2].layer.add(rotateAnimation, forKey: nil)
        seatLabels[3].layer.add(rotateAnimation, forKey: nil)
        
        CATransaction.commit()
    }
    
    func drawRelativeTable() {
        clearTable()
    }
	
	@objc func animateDealing(_ payload: Notification) { // TO IMPLEMENT
		let userInfo = payload.userInfo!
		let dealAmt = userInfo["dealAmt"] as! Int
        let dealerPos = userInfo["functionPosition"] as! Int
        let sourcePos = userInfo["sourcePos"] as? Int
		if dealAmt == 6 {
            dealHand(1, dealAmt: (Double)(dealAmt), dealerPos: dealerPos, sourcePos: sourcePos)
		} else {
            reDealHand(1, dealAmt: (Double)(dealAmt), dealerPos: dealerPos, sourcePos: sourcePos)
		}
	}
	
	@objc func clearTableWithFade(_ payload: Notification) {
		let userInfo = payload.userInfo!
		let fade = userInfo["fade"] as? Double
		let delay = userInfo["delay"] as? Double
		clearTableWithFade(fade: fade, delay: delay)
	}
		
	func clearTableWithFade(fade: Double?, delay: Double?, _ complete: (()->())? = nil) {
		UIView.animate(withDuration: fade.or(2.0),
           delay: delay.or(0),
           options: [UIView.AnimationOptions.curveEaseIn],
           animations: {
            for view in self.tableCardViews {
                let face = view.subviews[0] as! UIImageView
                face.alpha = 0
                view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1)
            }
		}, completion: { (finished: Bool) -> Void in
			for (cardView) in self.tableCardViews {
				let face = cardView.subviews[0] as! UIImageView
				face.image = nil
				face.tag = 0
				face.alpha = 1
			}
			complete?()
		})
	}
	
	fileprivate func getGlobalPosition(_ view: UIView) ->(x:CGFloat, y:CGFloat)? {
		if let pos = view.superview?.convert(view.frame.origin, to: nil) {
			return (x:pos.x, y:pos.y)
		}
		return nil
	}
	
	@objc func animateTrick(_ payload: Notification) { // TO IMPLEMENT
		let userInfo = payload.userInfo!
        let winningPosition = userInfo["functionPosition"] as! Int
        let sourcePos = userInfo["sourcePos"] as? Int
		let pos = playerCoords(winningPosition)
		var roundCardViews = [UIImageView]()
		for i in 0..<4 {
			let gPos = getGlobalPosition(tableCardViews[i])!
			let cardView = UIImageView(frame:CGRect(x: gPos.x, y: gPos.y, width: cardDim.0, height: cardDim.1))
			cardView.autoresizesSubviews = true
			initializeCardImageView(cardView, radius: 4.0, addBackView: false)
			cardView.backgroundColor = UIColor(red: 1, green: 1, blue: 0.95, alpha: 1)
			(cardView.subviews[0] as! UIImageView).image = (tableCardViews[i].subviews[0] as! UIImageView).image
			view.addSubview(cardView)
			roundCardViews.append(cardView)
		}
	
		clearTable()
		clearTurns()
	
		UIView.animate(withDuration: 0.25,
			delay: 0,
			options: [UIView.AnimationOptions.curveEaseIn],
			animations: {
				for view in roundCardViews {
					view.frame = CGRect(x: pos!.x, y: pos!.y, width: 45, height: 62)
					view.alpha = 0
					view.transform = CGAffineTransform(rotationAngle: .pi)
				}
			}, completion: { (finished: Bool) -> Void in
				for view in roundCardViews {
					view.removeFromSuperview()
				}
                self.gameViewModel?.animateTrickComplete(sourcePos)
		})
	}
	
    fileprivate func dealHand(_ playerCount: Int, dealAmt: Double, dealerPos: Int, sourcePos: Int?) {
		if playerCount > 4 {
			audioData.dealSound?.stop()
			gameViewModel?.dealHandComplete(sourcePos)
		} else {
            animateDealCards(playerCount, dealAmt: dealAmt, dealerPos: dealerPos, sourcePos: sourcePos)
		}
	}
	
    fileprivate func reDealHand(_ playerCount: Int, dealAmt: Double, dealerPos: Int, sourcePos: Int?) {
		if playerCount > 4 {
			audioData.dealSound?.stop()
			gameViewModel?.reDealHandComplete(sourcePos)
		} else {
            animateDealCards(playerCount, dealAmt: dealAmt, dealerPos: dealerPos, sourcePos: sourcePos)
		}
	}
	
    fileprivate func animateDealCards(_ playerCount: Int, dealAmt: Double, dealerPos: Int, sourcePos: Int?) {
		let p = (dealerPos + playerCount) % 4
		for i in 0..<(Int)(dealAmt) {
            animateDealCard((Double)(i), pos: p, playerCount: playerCount, dealAmt: dealAmt, dealerPos: dealerPos, sourcePos: sourcePos)
		}
	}
	
	fileprivate func placeholderCoords(_ tag:Int) ->(x:CGFloat, y:CGFloat, w:CGFloat, h:CGFloat)? {
		if let viewPos = view.superview?.convert(view.frame.origin, to: nil) {
			if let placeHolder = view.superview?.viewWithTag(tag) {
				if let pos = placeHolder.superview?.convert(placeHolder.frame.origin, to: nil) {
					return (
						x:pos.x-viewPos.x,
						y:pos.y-viewPos.y,
						w:placeHolder.frame.width,
						h:placeHolder.frame.height
					)
				}
			}
		}
		
		return nil
	}
	
	@objc func animatePlayCard(_ payload: Notification) {
 		let userInfo = payload.userInfo!
        let pos = userInfo["functionPosition"] as? Int
        let sourcePos = userInfo["sourcePos"] as? Int
		let cardIndex = userInfo["cardIndex"] as! Int
		
        animateThirdPartyPlayCard(pos: pos!, cardIndex: cardIndex, sourcePos: sourcePos)
	}
	
    func animateThirdPartyPlayCard(pos: Int, cardIndex: Int, sourcePos: Int?) {
        if pos == 0 { return }
   		print("*****", "pos:\(pos)", "cardIndex:\(Card.getCardDescription(cardIndex))")
		print("*****")
		var origX: CGFloat = 0; var origY: CGFloat = 0
		var destX: CGFloat = 0; var destY: CGFloat = 0
		var destW: CGFloat = 0
		var destH: CGFloat = 0
		
		if let orig = playerCoords(pos) {
			origX = orig.x
			origY = orig.y
		}
		if let placeHolder = placeholderCoords(200+pos) {
			destX = placeHolder.x
			destY = placeHolder.y
			destW = placeHolder.w
			destH = placeHolder.h
		}

		let playCardView = UIImageView(frame:CGRect(x: origX, y: origY, width: 45, height: 62))
		playCardView.autoresizesSubviews = true
		initializeCardImageView(playCardView, radius: 4.0)
		playCardView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.95, alpha: 1.0)

		let cardFace = playCardView.subviews[0] as! UIImageView
		let imageName = Card.getImageName(cardIndex)
		cardFace.image = UIImage(named: imageName)
		playCardView.tag = cardIndex
		
		view.addSubview(playCardView)
			
		let duration: Double = 0.15
		UIView.animate(withDuration: duration,
			delay: 0,
			options: UIView.AnimationOptions(),
			animations: {
				playCardView.transform = CGAffineTransform(rotationAngle: 0)
				playCardView.frame = CGRect(x: destX, y: destY, width: destW, height: destH)
				let w = playCardView.frame.width * 0.85
				let h = playCardView.frame.height * 0.85
				let x1 = playCardView.frame.width * (1 - 0.85) / 2
				let y1 = playCardView.frame.height * (1 - 0.85) / 2
				playCardView.subviews[0].frame = CGRect(x: x1, y: y1, width: w, height: h)
			}, completion: { (finished: Bool) -> Void in
				self.audioData.playCardSound()
                Int.delay(0.4) {
                    playCardView.removeFromSuperview()
                }
                // prevent robots from adding card to tableview
                // before remote notification (as done for human)
                if self.gameViewModel?.game == nil { return }
                self.gameViewModel?.onCardPlayAnimationComplete(cardIndex, playerIndex: pos, sourcePos: sourcePos)
		})
	}
	
    fileprivate func animateDealCard(_ i: Double, pos: Int, playerCount: Int, dealAmt: Double, dealerPos: Int, sourcePos: Int?) {
		var x: CGFloat = 0; var y: CGFloat = 0
		if let coords = playerCoords(pos) {
			x = coords.x
			y = coords.y
		}
		let dim = (kickView.frame.width, kickView.frame.height)
		let dealCardView = UIImageView(frame:CGRect(x: 0, y: 0, width: dim.0, height: dim.1))
		dealCardView.autoresizesSubviews = true
		initializeCardImageView(dealCardView, radius: 4.0, addBackView: true)
		
		let originalCenter = kickView.superview?.convert(kickView.frame.origin, to: nil)
		dealCardView.center = CGPoint(
			x: originalCenter!.x + dim.0 / 2,
			y: originalCenter!.y + dim.1 / 2
		)
		view.addSubview(dealCardView)
		let duration: Double = 0.4
		clearKick()
		UIView.animate(withDuration: duration,
			delay: i * 0.1,
			options: [UIView.AnimationOptions.curveLinear],
			animations: {
				dealCardView.frame = CGRect(x: x, y: y, width: 45, height: 62)
				dealCardView.alpha = 0
			}, completion: { (finished: Bool) -> Void in
				dealCardView.removeFromSuperview()
				if i == dealAmt-1 {
					if dealAmt == 6 {
                        self.dealHand(playerCount+1, dealAmt:dealAmt, dealerPos: dealerPos, sourcePos: sourcePos)
					} else {
                        self.reDealHand(playerCount+1, dealAmt:dealAmt, dealerPos: dealerPos, sourcePos: sourcePos)
					}
				}
		})
		audioData.playSound(audioData.dealSound)
		rotate(dealCardView, repeats: 16, i: (CGFloat)(i))
		rotate(kickView, repeats: 8, i: 0)
	}
	
	fileprivate func playerCoords(_ pos: Int) ->(x:CGFloat, y:CGFloat)? {
		let east = view.viewWithTag(101)!
		let west = view.viewWithTag(103)!
		let posE = east.superview?.convert(east.frame.origin, to: nil)
		let posW = west.superview?.convert(west.frame.origin, to: nil)
		switch(pos) {
		case 0: return ((CGFloat)(view.bounds.width) / (CGFloat)(2), y:(CGFloat)(view.bounds.height))
		case 1: return ((CGFloat)(view.bounds.width), y:(CGFloat)(posE!.y + (east.bounds.height / 2) - 31))
		case 2: return ((CGFloat)(view.bounds.width) / (CGFloat)(2) - 22, y:(CGFloat)(-62))
		case 3: return ((CGFloat)(-45), y:(CGFloat)(posW!.y + (west.bounds.height / 2) - 31))
		default: break
		}
		return nil
	}
	
	fileprivate func avatarChatCoords(_ pos: Int) ->(x:CGFloat, y:CGFloat)? {
		let south = view.viewWithTag(100)!
		let east = view.viewWithTag(101)!
		let north = view.viewWithTag(102)!
		let west = view.viewWithTag(103)!
		let posS = south.superview?.convert(south.frame.origin, to: nil)
		let posE = east.superview?.convert(east.frame.origin, to: nil)
		let posN = north.superview?.convert(north.frame.origin, to: nil)
		let posW = west.superview?.convert(west.frame.origin, to: nil)
		switch(pos) {
		case 0: return ((CGFloat)(posS!.x) + (CGFloat)(40), y:(CGFloat)(posS!.y) - (CGFloat)(40))
		case 1: return ((CGFloat)(posE!.x), y:(CGFloat)(posE!.y))
		case 2: return ((CGFloat)(posN!.x) + (CGFloat)(40), y:(CGFloat)(posN!.y))
		case 3: return ((CGFloat)(posW!.x) + (CGFloat)(40), y:(CGFloat)(posW!.y))
		default: break
		}
		return nil
	}
	
	fileprivate func rotate(_ view: UIView, repeats: CGFloat, i: CGFloat, totalRepeats: CGFloat? = nil) {
		var tr = totalRepeats
		if repeats == 0 {return}
		if totalRepeats == nil {tr = repeats}
		UIView.animate(withDuration: 0.1,
			delay: 0,
			options: [UIView.AnimationOptions.curveLinear],
			animations: {
				view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) * (tr! - repeats))
			}, completion: { (finished: Bool) -> Void in
				self.rotate(view, repeats: repeats - 1, i: i, totalRepeats: tr)
		})
	}
	
    @objc func cardPlayed(_ payload: Notification) {
        let userInfo = payload.userInfo!
        guard let round = userInfo["currRound"] as? [String: Any] else {return}
        guard let firstPos = userInfo["functionPosition"] as? Int else {return}
        guard let plays = round["plays"] as? [[String: Any]] else {return}
        
        updateTable(firstPos: firstPos, plays: plays)
        if !OWNER { return }
        hideModalViews()
        gameViewModel?.nextState()
    }
    
    @objc func clientCardPlayed(_ payload: Notification) {
        let userInfo = payload.userInfo!
        guard let play = userInfo["play"] as? [String: Any] else {return}
        updateClientTableCard(play)
    }
	
    @objc func newRound(_ payload: Notification) {
		let userInfo = payload.userInfo!
        guard let firstPos = userInfo["functionPosition"] as? Int else {return}
        guard let plays = userInfo["plays"] as? [[String: Any]] else {return}
        updateTable(firstPos: firstPos, plays: plays)
	}
	
	@objc func updateGamePoints(_ payload: Notification) {
        if let score = payload.userInfo?["gamePoints"] as? [Int] {
            if let pos = payload.userInfo?["sourcePos"] as? Int {
//                let mySub = pos % 21`
                if let mySub = gameViewModel?.getMySub(ownerIndex: pos) {
                    gamePoints0.text = score[mySub] == 0 ? "" : "\(score[mySub])"
                    gamePoints1.text = score[1 - mySub] == 0 ? "" : "\(score[1 - mySub])"
                }
            } else {
                gamePoints0.text = score[0] == 0 ? "" : "\(score[0])"
                gamePoints1.text = score[1] == 0 ? "" : "\(score[1])"
            }
        }
	}
	
	@objc func updateScore(_ payload: Notification) {
		if let score = payload.userInfo?["score"] as? [Int] {
//            score = [12,9]
            if let pos = payload.userInfo?["sourcePos"] as? Int {
                if let mySub = gameViewModel?.getMySub(ownerIndex: pos) {
                    score0.text = "\(score[mySub])"
                    score1.text = "\(score[1 - mySub])"
                    setMatchScore(score[mySub], matchesView: matchesStack0)
                    setMatchScore(score[1 - mySub], matchesView: matchesStack1)
                }
            } else {
                score0.text = "\(score[0])"
                score1.text = "\(score[1])"
                setMatchScore(score[0], matchesView: matchesStack0)
                setMatchScore(score[1], matchesView: matchesStack1)
            }
		}
	}
	
	func setMatchScore(_ score: Int, matchesView: UIView) {
		clearMatchesFromView(matchesView)
		if score == 0 {return}
		let mod = min(score, 14) % 5
		let groupIndex = min((Int)(floor((Double(score / 5))) + 1), 3)
		for i in 0..<groupIndex {
			let group = matchesView.subviews[i].subviews[0] as! UIStackView
			group.isHidden = false
			if i < groupIndex - 1 {
				group.arrangedSubviews.forEach{$0.isHidden = false}
			} else {
				group.arrangedSubviews.enumerated().filter{(i, v) in
					i < mod}.forEach{$1.isHidden = false}
			}
		}
	}
	
	func clearMatches() {
		clearMatchesFromView(matchesStack0)
		clearMatchesFromView(matchesStack1)
	}

	func clearMatchesFromView(_ matchesView: UIView) {
		matchesView.subviews.map{$0.subviews[0] as? UIStackView}
            .compactMap{$0?.arrangedSubviews}
			.flatMap{$0}
			.forEach{$0.isHidden = true}
	}
	
    @objc func updateKick(_ payload: Notification) {
		let userInfo = payload.userInfo!
        let index = userInfo["index"] as? Int
        let imageName = userInfo["imageName"] as? String
        if index == nil || imageName == nil {
             return clearKick()
        }
		let inner = kickView.subviews[0] as! UIImageView
		inner.image = UIImage(named: imageName!)
		inner.tag = index!
		flip(kickView.subviews[1], view2: inner)
		kickLabel.alpha = 0.6
	}
	
	func getBorderColors() -> [CGColor?] {
		return [
			tableCardViews[0].layer.borderColor,
			tableCardViews[1].layer.borderColor,
			tableCardViews[2].layer.borderColor,
			tableCardViews[3].layer.borderColor
		]
	}
	
	func getBorderWidths() -> [CGFloat?] {
		return [
			tableCardViews[0].layer.borderWidth,
			tableCardViews[1].layer.borderWidth,
			tableCardViews[2].layer.borderWidth,
			tableCardViews[3].layer.borderWidth
		]
	}

    func updateTable(firstPos: Int, plays: [[String: Any]]) {
        clearTable() // TODO: call from gameViewModel
		for (i, play) in plays.enumerated() {
			let cardView = tableCardViews[(firstPos+i) % 4]
			let front = cardView.subviews[0] as! UIImageView
			front.image = UIImage(named: play["imageName"] as! String)
			front.tag = play["index"] as! Int
			cardView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.95, alpha: 1.0)
		}
	}

    func updateClientTableCard(_ play: [String: Any]) {
        let cardView = tableCardViews[0]
        let front = cardView.subviews[0] as! UIImageView
        front.image = UIImage(named: play["imageName"] as! String)
        front.tag = play["index"] as! Int
        cardView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.95, alpha: 1.0)
    }

	@objc func animateDraw(_ payload: Notification) {
		let userInfo = payload.userInfo!
        var currPos = userInfo["functionPosition"] as! Int
        let sourcePos = userInfo["sourcePos"] as? Int
		var drawnCards = userInfo["drawnCards"] as! [String]
		if drawnCards.count == 0 {return}

		DispatchQueue.main.async {
            var unFlippedCardCount = drawnCards.count
			_ = Timer.schedule(repeatInterval: 0.1) { timer in
				let imageName = drawnCards.removeFirst()
				currPos = (currPos + 1) % 4
				if drawnCards.count == 0 {
					timer?.invalidate()
				}
				self.animateDrawCard(position: currPos, imageName: imageName) { _ in
					unFlippedCardCount -= 1
					if unFlippedCardCount == 0 {
						self.clearTableWithFade(fade: 2.0, delay: 3.0)
                        self.gameViewModel?.animateDrawCardComplete(currPos, sourcePos: sourcePos)
					}
				}
			}
		}
	}
	
	func animateDrawCard(position: Int, imageName: String, complete: ((Bool)->())? = nil) {
		let cardView = tableCardViews[position]
		let prevCardView = cardView
		let front = cardView.subviews[0] as! UIImageView
		front.image = UIImage(named: imageName)
		cardView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.95, alpha: 1.0)
		flip(prevCardView.subviews[0], view2: cardView.subviews[0], complete: complete)
	}
	
	@objc func updateTurn(_ payload: Notification) {
		let userInfo: Dictionary = payload.userInfo!
		let currPosition = userInfo["functionPosition"] as! Int
		clearTurns()
		tableCardViews.enumerated().forEach{(i, view) in
			if i == currPosition {
				view.layer.borderColor = .highlightBorder
				view.layer.borderWidth = 2.0
			} else {
				view.layer.borderColor = .defaultBorder
				view.layer.borderWidth = 1.0
			}
		}
	}

	@objc func hideModalView(_ payload: Notification) {
		hideModalViews()
	}
	
	func hideModalViews() {
		modalView.isHidden = true
		wonStackView.isHidden = true
		lostStackView.isHidden = true
		beggarOptionsStackView.isHidden = true
		dealerOptionsStackView.isHidden = true
		scoreNamesStackView.isHidden = true
		
		infoStackLabel.isHidden = true
		
		weHighLabel.isHidden = true
		weLowLabel.isHidden = true
		weJackLabel.isHidden = true
		weHangJackLabel.isHidden = true
		weGameLabel.isHidden = true
		demHighLabel.isHidden = true
		demLowLabel.isHidden = true
		demJackLabel.isHidden = true
		demHangJackLabel.isHidden = true
		demGameLabel.isHidden = true
	}
	
	@objc func showWon(_ payload: Notification) {
		hideModalViews()
        modalView.isHidden = false
        guard let userInfo: Dictionary = payload.userInfo else {
            wonStackView.isHidden = false
            return
        }
        if let sourcePos = userInfo["sourcePos"] as? Int {
            if sourcePos % 2 == 0 {
                wonStackView.isHidden = false
            } else {
                lostStackView.isHidden = false
            }
        }
	}
	
	@objc func showLost(_ payload: Notification) {
		hideModalViews()
		modalView.isHidden = false
        
        guard let userInfo: Dictionary = payload.userInfo else {
            lostStackView.isHidden = false
            return
        }
        if let sourcePos = userInfo["sourcePos"] as? Int {
            if sourcePos % 2 == 0 {
                lostStackView.isHidden = false
            } else {
                wonStackView.isHidden = false
            }
        }
	}
	
	@objc func showContinue(_ payload: Notification) {
        hideModalViews()
        startWait.isHidden = OWNER
        startNowBtn.isHidden = !OWNER
        startNowBtn.titleLabel?.text = "PLAY"
	}
    
    @objc func showBeggarOptions(_ payload: Notification) {
        if let userInfo = payload.userInfo {
            guard let funcPos = userInfo["functionPosition"] as? Int else {
                return
            }
            if funcPos != 0 { return }
        }
        hideModalViews()
        modalView.isHidden = false
        beggarOptionsStackView.isHidden = false
    }
	
	@objc func showDealerOptions(_ payload: Notification) {
        if let userInfo = payload.userInfo {
            guard let funcPos = userInfo["functionPosition"] as? Int else {
                return
            }
            if funcPos != 0 { return }
        }
		hideModalViews()
		modalView.isHidden = false
		dealerOptionsStackView.isHidden = false
	}
	
	func showInfo(_ text: String) {
		hideModalViews()
		modalView.isHidden = false
		infoStackLabel.isHidden = false
		infoStackLabel.text = text
	}
	
	@objc func showScoreNames(_ payload: Notification) { //TO IMPLEMENT
        guard let userInfo = payload.userInfo else { return }
		let scoreNames = userInfo["scoreNames"] as! [[String]]
        let origSourcePos = userInfo["sourcePos"] as? Int
        let sourcePos = origSourcePos ?? 0
		hideModalViews()
		modalView.isHidden = false
		scoreNamesStackView.isHidden = false
        if let mySub = gameViewModel?.getMySub(ownerIndex: sourcePos) {
            for sn in scoreNames[mySub] {
                switch (sn) {
                case "high": weHighLabel.isHidden = false
                case "low": weLowLabel.isHidden = false
                case "jack": weJackLabel.isHidden = false
                case "hangjack": weHangJackLabel.isHidden = false
                case "game": weGameLabel.isHidden = false
                default: return
                }
            }
            for sn in scoreNames[1 - mySub] {
                switch (sn) {
                case "high": demHighLabel.isHidden = false
                case "low": demLowLabel.isHidden = false
                case "jack": demJackLabel.isHidden = false
                case "hangjack": demHangJackLabel.isHidden = false
                case "game": demGameLabel.isHidden = false
                default: return
                }
            }
        }
        if origSourcePos == nil {
            gameViewModel?.showScoreNamesComplete(nil)
        } else {
            gameViewModel?.showScoreNamesComplete(sourcePos)
        }
    }
	
	func showBubble(_ msg: String, pos: Int, delay: Double=1, cb:@escaping ()->()) {
		if let point = avatarChatCoords(pos) {
			let bubble = ChatBubbleView(X: point.x, Y: point.y, pos: pos)
			bubble.addText(msg)
			self.view.addSubview(bubble)
            view.endEditing(false)
            bubble.animate(delay, cb: cb)
			print(msg)
		}
	}

	@objc func beg(_ payload: Notification) {
		guard let userInfo = payload.userInfo else {return}
		let msg = userInfo["msg"] as! String
		let pos = userInfo["functionPosition"] as! Int
        let sourcePos = userInfo["sourcePos"] as? Int
		showBubble(msg, pos: pos, cb: {() in
			self.gameViewModel?.begComplete(sourcePos)
		})
	}
	
	@objc func stand(_ payload: Notification) { //TO IMPLEMENT
		guard let userInfo = payload.userInfo else {return}
		let msg = userInfo["msg"] as! String
		let pos = userInfo["functionPosition"] as! Int
        let sourcePos = userInfo["sourcePos"] as? Int
//		let pos = (dealerPos + 1) % 4
		showBubble(msg, pos: pos, cb: {() in
			self.gameViewModel?.standComplete(sourcePos)
		})
		self.hideModalViews()
	}
	
	@objc func takeOne(_ payload: Notification) { //TO IMPLEMENT
		let userInfo = payload.userInfo!
		let msg = userInfo["msg"] as! String
		let pos = userInfo["functionPosition"] as! Int
        let sourcePos = userInfo["sourcePos"] as? Int
		showBubble(msg, pos: pos, cb: {() in
			self.gameViewModel?.takeOneComplete(sourcePos)
		})
	}
	
	@objc func reDeal(_ payload: Notification) { //TO IMPLEMENT
		let userInfo = payload.userInfo!
		let msg = userInfo["msg"] as! String
        let pos = userInfo["functionPosition"] as! Int
        let sourcePos = userInfo["sourcePos"] as? Int
		showBubble(msg, pos: pos, cb: {() in
			self.gameViewModel?.reDealComplete(sourcePos)
		})
	}

	@objc func sameTrump(_ payload: Notification) {
        let userInfo = payload.userInfo!
		let msg = userInfo["msg"] as! String
        let sourcePos = userInfo["sourcePos"] as? Int
		showInfo(msg)
		Int.delay(1) {
			self.hideModalViews()
            self.gameViewModel?.sameTrumpComplete(sourcePos)
		}
	}
	
	func clearAll() {
		hideModalViews()
		clearTable()
		clearKick()
	}
	
	@objc func clearTable() {
        for (cardView) in tableCardViews {
			let face = cardView.subviews[0] as! UIImageView
            face.image = nil
			face.tag = 0
            cardView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1)
        }
    }
    
    func clearTurns() {
        for cardView in tableCardViews {
            cardView.layer.borderColor = .defaultBorder
        }
    }
    
    func clearKick() {
		flip(kickView.subviews[0], view2: kickView.subviews[1])
    }
	
	func initializeStartNowButton() {
        startNowBtn.isHidden = true

		startNowBtn.layer.cornerRadius = 8.0
		startNowBtn.clipsToBounds = true
		startNowBtn.backgroundColor = themeAverage
		startNowBtn.contentMode = .center
		startNowBtn.layer.borderColor = .defaultBorder
		startNowBtn.layer.borderWidth = 1.0
        
        startNowBtn.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        startNowBtn.setTitle("Creating Game...", for: .disabled)
	}
    
    func createHandImageView() {
		if hVC == nil {return}
        addChild(hVC!)
		hVC!.back = back
		let frame = CGRect(x: 0,y: 0,width: 0,height: 0)
        hVC!.view = UIImageView(frame: frame)
        hVC!.view.backgroundColor = UIColor(white: 0, alpha: 0)
		bottomSectionView.addSubview(hVC!.view)
		hVC!.didMove(toParent: self)
		
		hVC!.view.translatesAutoresizingMaskIntoConstraints = false
		
        let bottomConstraint = NSLayoutConstraint(item: hVC!.view as Any, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bottomSectionView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
		bottomSectionView.addConstraint(bottomConstraint)
		
        let topConstraint = NSLayoutConstraint(item: hVC!.view as Any, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bottomSectionView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
		bottomSectionView.addConstraint(topConstraint)
		
        let leftConstraint = NSLayoutConstraint(item: hVC!.view as Any, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bottomSectionView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
		bottomSectionView.addConstraint(leftConstraint)
		
        let rightConstraint = NSLayoutConstraint(item: hVC!.view as Any, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bottomSectionView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
		bottomSectionView.addConstraint(rightConstraint)
    }
	
    func initializeCardImageViews() {
        for cardView in tableCardViews {
            initializeCardImageView(cardView)
        }
		initializeCardImageView(kickView, radius: 4.0, addBackView: true)
		kickView.backgroundColor = UIColor(red: 1, green: 1, blue: 0.95, alpha: 1)
	}
	
	func switchCardFaces(_ facesName: String) {
		for view in tableCardViews {
			let front = view.subviews[0] as! UIImageView
			if front.tag > 0 {
				front.image = UIImage(named: facesName + "-card" + (String)(front.tag+1))
				view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.95, alpha: 1.0)
			}
		}
		
		guard let kickFace = kickView.subviews[0] as? UIImageView else {return}
		if kickFace.tag > 0 {
			kickFace.image = UIImage(named: facesName + "-card" + (String)(kickFace.tag+1))
		}
	}
	
	func removeKickTapRecognizer() {
		for sv in kickView.subviews {
			for recognizer in sv.gestureRecognizers! {
				sv.removeGestureRecognizer(recognizer)
			}
		}
	}
	
	func addKickTapRecognizer() {
		let singleTap = UITapGestureRecognizer(target: self, action: #selector(RootViewController.newGame(_:)))
		singleTap.numberOfTapsRequired = 1
		singleTap.numberOfTouchesRequired = 1
		kickView.isUserInteractionEnabled = true
		
		kickView.addGestureRecognizer(singleTap)
	}
	
	func initializeCardImageView(_ cardView: UIImageView, radius: CGFloat = 8.0, addBackView: Bool = false) {
		for sv in cardView.subviews {
			sv.removeFromSuperview()
		}
        cardView.layer.cornerRadius = radius
        cardView.clipsToBounds = true
		cardView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1)
        cardView.contentMode = .center
        cardView.layer.borderColor = .defaultBorder
		cardView.layer.borderWidth = 1.0
		addCardFace(cardView)
		if addBackView {addCardBack(cardView)}
	}
	
	func addCardFace(_ cardView: UIImageView, scale: CGFloat = 0.85) {
		let w = cardView.frame.width * scale
		let h = cardView.frame.height * scale
		let x = cardView.frame.width * (1 - scale) / 2
		let y = cardView.frame.height * (1 - scale) / 2
		let innerCardView = UIImageView()
		innerCardView.clipsToBounds = true
		innerCardView.frame = CGRect(x: x, y: y, width: w, height: h)
		cardView.addSubview(innerCardView)
	}
	
	func addCardBack(_ cardView: UIImageView) {
		let w = cardView.frame.width
		let h = cardView.frame.height
		let backCardView = UIImageView()
		backCardView.clipsToBounds = true
		backCardView.frame = CGRect(x: 0, y: 0, width: w, height: h)
		backCardView.image = back
		if cardView.subviews.count > 1 {
			if let view = cardView.subviews[1] as? UIImageView {
				view.clipsToBounds = true
				view.frame = CGRect(x: 0, y: 0, width: w, height: h)
				view.image = back
			}
			return
		}
		cardView.addSubview(backCardView)
	}
	
	func flip(_ view1: UIView, view2: UIView, complete: ((Bool)->())? = nil) {
		let animationOptions: UIView.AnimationOptions = [UIView.AnimationOptions.transitionFlipFromRight, UIView.AnimationOptions.showHideTransitionViews]
		UIView.transition(from: view1, to: view2, duration: 0.4, options: animationOptions, completion: complete)
	}
	
}
