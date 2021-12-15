//
//  HandViewController.swift
//  War
//
//  Created by Adrian Bartholomew2 on 12/29/15.
//  Copyright © 2015 GB Software. All rights reserved.
//

import UIKit
import AVFoundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

protocol Sittable: class {
	func onSit(_ position: Int)
}

class HandViewController: UIViewController, Sittable, UIGestureRecognizerDelegate {
	let Q = StateQueue.sharedInstance
	let audioData = AudioData.sharedInstance

	weak var playable: Playable?
	
	var handViewModel: HandViewModel!
	
	let shrinkThreshold: Int = 9
	let edgeFactor: CGFloat = 0.92
//	let edgeFactor: CGFloat = 1
	let cardAspectRatio: CGFloat = 90/125
	
	var position: Int? // Seat Position - name properly so we can lose this comment
	var handViewWidth: CGFloat?
    var handCardViews = [UIImageView]()
    var handCardSep: CGFloat?
	var cardWidth: CGFloat? {
		didSet {
			cardHeight = cardWidth! / cardAspectRatio
		}
	}
	var cardHeight: CGFloat?
	var tableCardWidth: CGFloat?
	var tableCardHeight: CGFloat?
	var playCardCallback: (UIImageView, Card)->Void = { _,_  in }
    
    var snapX:CGFloat = 1.0
    var snapY:CGFloat = 1.0
    /// how far to move before dragging
    var threshold:CGFloat = 0.0
    /// the guy we're dragging
    var selectedView:UIView?
    var shouldDragY = false
	var shouldDragX = true
	var origCenter:CGPoint?
	
	var back: UIImage? {
		didSet {updateCardImages()}
	}
    
	init(_ handViewModel: HandViewModel) {
		self.handViewModel = handViewModel
		back = UIImage(named: "card1")
        super.init(nibName: nil, bundle: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(HandViewController.animatePlayCard(_:)), name: NSNotification.Name(rawValue: "animateFirstPersonPlayCard"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		handViewWidth = view.frame.size.width * edgeFactor
		setOptimumCardWidth()
		createHandViewGestures()
	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
		removeGestureRecognizers([view])
		selectedView = nil
		handCardViews = [UIImageView]()
	}
	
	func createHandViewGestures() {
		view.isUserInteractionEnabled = true
		let fatTap = UITapGestureRecognizer(target: self, action: #selector(self.sortHand(_:)))
		fatTap.numberOfTapsRequired = 1
		fatTap.numberOfTouchesRequired = 2
		view.addGestureRecognizer(fatTap)
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	func updateHandView(cardTuples: [(String, Int)]) {
		removeGestureRecognizers(handCardViews)
		handCardViews = []
		view.subviews.forEach({$0.removeFromSuperview()})
		setOptimumCardWidth(CGFloat(cardTuples.count))
		cardTuples.forEach({addNewHandCardImage($0)})
		layoutHandCardViews()
	}
	
	func vibrateCardView(_ cardIndex: Int) {
		print("vibrating for", cardIndex)
		guard let view = findViewByTag(cardIndex) else {return}
		view.shakeView()
	}
	
	func addNewHandCardImage(_ card: (imageName:String, index:Int)) {
		let cardView  = UIImageView(frame:CGRect(x: 0, y: 0, width: cardWidth!, height: cardHeight!));

		prepareCardImage(cardView)
		let cardFace = cardView.subviews[1] as! UIImageView
		cardFace.image = UIImage(named: card.imageName)
		cardView.tag = card.index
		view.addSubview(cardView)
		handCardViews.append(cardView)
		addEventRecognizers(cardView)
	}
	
	func onSit(_ position: Int) {
		self.position = position
	}

	@objc func animatePlayCard(_ payload: Notification) {
		let userInfo = payload.userInfo!
        let cardIndex = userInfo["cardIndex"] as! Int
        let sourcePos = userInfo["sourcePos"] as? Int
		
		guard let view = findViewByTag(cardIndex) else {
			print ("play card view not found")
			return
		}
		guard let rect = placeholderCoords() else {return}
		let w = rect.w
		let h = rect.h
		let x = rect.x
		let y = rect.y
		let w1 = w * 0.85
		let h1 = h * 0.85
		let x1 = rect.w * (1 - 0.85) / 2
		let y1 = rect.h * (1 - 0.85) / 2

		let duration: Double = 0.15
		UIView.animate(withDuration: duration,
			delay: 0,
			options: UIView.AnimationOptions(),
			animations: {
				view.transform = CGAffineTransform(rotationAngle: 0)
				view.frame = CGRect(x: x, y: y, width: w, height: h)
				view.subviews[1].frame = CGRect(x: x1, y: y1, width: w1, height: h1)
			}, completion: { (finished: Bool) -> Void in
				self.audioData.playCardSound()
                self.handViewModel.onPlayAnimationComplete(view.tag, sourcePos: sourcePos)
		})
	}
	
	fileprivate func placeholderCoords() ->(x:CGFloat, y:CGFloat, w:CGFloat, h:CGFloat)? {
		let viewPos = view.convert(view.frame.origin, to: nil)
		if let placeHolder = view.superview?.superview?.viewWithTag(200) {
			if let pos = placeHolder.superview?.convert(placeHolder.frame.origin, to: nil) {
				let w = placeHolder.frame.width
				let h = placeHolder.frame.height
				return (x:pos.x-viewPos.x, y:pos.y-viewPos.y, w:w, h:h)
			}
		}
		return nil
	}
	
	fileprivate func rotate(_ view: UIView) {
		UIView.animate(withDuration: 0.4,
			delay: 0,
			options: [UIView.AnimationOptions.curveLinear],
			animations: {
				view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
			}, completion: nil
		)
	}
	
	func revealHandView(_ show: Bool) {
		for view in handCardViews {
			if show {
				flip(view.subviews[0], view2: view.subviews[1])
			} else {
				revealCard(view, show: false)
			}
		}
	}
	
	func revealCard(_ cardView: UIView, show: Bool = true) {
		cardView.subviews[0].isHidden = show
		cardView.subviews[1].isHidden = !show
	}
	
	func flip(_ view1: UIView, view2: UIView) {
		let animationOptions: UIView.AnimationOptions = [UIView.AnimationOptions.transitionFlipFromRight, UIView.AnimationOptions.showHideTransitionViews]
		UIView.transition(from: view1, to: view2, duration: 0.4, options: animationOptions, completion: nil)
	}
	
	func switchCardFaces(_ facesName: String) {
		for cardView in handCardViews {
			let cardFace = cardView.subviews[1] as! UIImageView
			let index = cardView.tag
			cardFace.image = UIImage(named: facesName + "-card" + (String)(index+1))
		}
	}
	
    func getAverageAngle(_ inc: CGFloat) -> CGFloat {
        let count = self.handCardViews.count
        var total: CGFloat = 0
        for i in 0..<count {
            total += CGFloat(i) * inc
        }
        return total / CGFloat(count)
    }
	
	func setOptimumCardWidth(_ count: CGFloat? = nil) {
		let threshold = count == nil || count! <= CGFloat(self.shrinkThreshold) ? CGFloat(self.shrinkThreshold) : 12
		cardWidth = (4 * handViewWidth!) / (CGFloat(threshold) + 3)
		handCardSep = cardWidth! / 4
	}
    
	func layoutHandCardViews() {
		let count: CGFloat = CGFloat(handCardViews.count)
		if count < 1 {return}
		
        let handWidth: CGFloat = cardWidth! + ((count-1) * handCardSep!)
		let edgeFactorOffset = view.frame.size.width * (1-edgeFactor) / 2
        let startX: CGFloat = edgeFactorOffset + ((handViewWidth! - handWidth) / 2 )
        let angInc: CGFloat = 0.05
        let avgAng: CGFloat = getAverageAngle(angInc)
        for i:Int in 0 ..< Int(count) {
            let ang = (CGFloat(i) * angInc) - avgAng
            let hc = handCardViews[Int(i)]
            hc.transform = CGAffineTransform(rotationAngle: 0)
			hc.frame.origin.x = startX + CGFloat(i)*handCardSep!
            hc.transform = CGAffineTransform(rotationAngle: ang)
        }
    }
	
    func updateCardImages() {
        for cardView in handCardViews {
            prepareCardImage(cardView)
        }
    }
    
    func prepareCardImage(_ cardView: UIImageView) {
        cardView.layer.cornerRadius = 8.0
        cardView.clipsToBounds = true
        cardView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.95, alpha: 1.0)
        cardView.contentMode = .center
        cardView.layer.borderColor = UIColor(white: 0, alpha: 0.5).cgColor
		cardView.layer.borderWidth = 1
		addCardBack(cardView)
		addCardFace(cardView)
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
		backCardView.layer.borderColor = UIColor(white: 0, alpha: 0.5).cgColor
		backCardView.layer.borderWidth = 1
		backCardView.isHidden = true
		cardView.addSubview(backCardView)
	}
	
	func removeGestureRecognizers(_ views: [UIView]) {
		for view in views {
			view.gestureRecognizers?.forEach{view.removeGestureRecognizer($0)}
		}
	}
	
	func addEventRecognizers(_ view: UIImageView) {

		view.isUserInteractionEnabled = true

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.highlightCard(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
		singleTap.cancelsTouchesInView = false
		singleTap.delegate = self
        view.addGestureRecognizer(singleTap)
		
		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.playCard(_:)))
		doubleTap.numberOfTapsRequired = 2
		doubleTap.numberOfTouchesRequired = 1
		view.addGestureRecognizer(doubleTap)
		singleTap.require(toFail: doubleTap)
		
		let swipe = UISwipeGestureRecognizer(target:self, action:#selector(self.playCard(_:)))
		swipe.direction = .up
		swipe.numberOfTouchesRequired = 1
		view.addGestureRecognizer(swipe)
		
		let pan = UIPanGestureRecognizer(target:self, action:#selector(self.pan(_:)))
		pan.maximumNumberOfTouches = 1
		pan.minimumNumberOfTouches = 1
		pan.require(toFail: swipe)
		view.addGestureRecognizer(pan)
		
	}
	
	@objc func pan(_ rec:UIPanGestureRecognizer) {
		selectedView = rec.view as? UIImageView
		let p:CGPoint = rec.location(in: view)
		
		switch rec.state {
		case .began:
			if selectedView != nil {
				origCenter = selectedView!.center
			}
		case .changed:
			if let subview = selectedView {
				if subview != view {
					if shouldDragX {
						let dP = rec.translation(in: subview)
						if let center = origCenter {
							
							subview.center.x = center.x + dP.x
						}
						let X = subview.frame.origin.x
						let viewBelow = getViewBelow(X)
						if viewBelow == nil {
							view.sendSubviewToBack(subview)
						}
						else {
							subview.transform = CGAffineTransform(rotationAngle: 0)
							view.insertSubview(subview, aboveSubview: viewBelow!)
							subview.transform = viewBelow!.transform
						}
					}
					if shouldDragY {
						subview.center.y = p.y - (p.y.truncatingRemainder(dividingBy: snapY))
					}
				}
			}
		case .ended:
			if let subview = selectedView {
				let X = subview.frame.origin.x
				if var position = handCardViews.firstIndex(where: {$0 == getViewBelow(X)}) {
					let currPos = handCardViews.firstIndex(where: {$0 == subview})
					if currPos > position {position += 1}
					handViewModel.onRepositionCard(cardIndex: subview.tag, newPos: position)
				} else {
					handViewModel.onRepositionCard(cardIndex: subview.tag, newPos: 0)
				}
			}
			selectedView = nil

		default:
			print("")
		}
	}
	
	func rotation(_ view: UIView) ->Float {
		let t = view.transform
		return atan2f((Float)(t.b), (Float)(t.a))
	}
	
	func getViewBelow(_ X: CGFloat) ->UIView? {
		for (_, hcv) in handCardViews.enumerated().reversed() {
			let posX = hcv.frame.origin.x
			if X > posX {return hcv}
		}
		return nil
	}
	
    @objc func highlightCard(_ sender: UITapGestureRecognizer) {
		guard sender.view != nil else { return }
		if sender.state == .ended {
			if sender.view == self.view {return}
			guard let imageView = sender.view as? UIImageView else {return}
			dehighlightCards()
			
            // simply changing the y value when already under rotation distorts
            // return rotation to 0, apply the new y then reapply cached rotation
            let zKeyPath = "layer.presentationLayer.transform.rotation.z"
            let imageRotation = (imageView.value(forKeyPath: zKeyPath) as? NSNumber)?.floatValue ?? 0.0
			imageView.transform = CGAffineTransform(rotationAngle: 0)
			UIView.animate(withDuration: 0.2, animations: {
				imageView.frame.origin.y -= 10
				imageView.backgroundColor = UIColor(red: 1, green: 1, blue: 0.8, alpha: 1)
			}) 

            imageView.transform = CGAffineTransform(rotationAngle: CGFloat(imageRotation))
        }
    }
    
    @objc func dehighlightCards() {
        for imageView in handCardViews {
            let zKeyPath = "layer.presentationLayer.transform.rotation.z"
            let origRotation = (imageView.value(forKeyPath: zKeyPath) as? NSNumber)?.floatValue ?? 0.0
            
			imageView.transform = CGAffineTransform(rotationAngle: 0)
			UIView.animate(withDuration: 0.1, animations: {
				imageView.frame.origin.y = 0
				imageView.backgroundColor = UIColor(red: 1, green: 1, blue: 0.95, alpha: 1)
			}) 

            imageView.transform = CGAffineTransform(rotationAngle: CGFloat(origRotation))
        }
    }

	func findViewByTag(_ tag: Int) ->UIView? {
		for view in handCardViews {
			if view.tag == tag {return view}
		}
		return nil
	}
	
	@objc func playCard(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			let imageView = sender.view as! UIImageView
			handViewModel.onPlayAttempt(imageView.tag)
		}
	}
	
	@objc func sortHand(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			handViewModel.sortHand()
		}
	}
    
    func removeHandCardViewTuple(_ imageView: UIImageView) -> UIImageView? {
        let index = handCardViews.firstIndex(where: {$0 == imageView})
        return removeCardFromHand(index!)
    }
    
    func removeCardFromHand(_ index: Int) -> UIImageView {
        let imageView = handCardViews.remove(at: index)
        imageView.gestureRecognizers?.forEach(imageView.removeGestureRecognizer)
        imageView.removeFromSuperview()
        layoutHandCardViews()
        return imageView
    }
    
}
