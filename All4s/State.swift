//
//  State.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/9/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

enum StateName: String {
	case suspend
    case start
	case first_JACK
	case first_DEAL
	case first_DEAL_ANIMATION
	case beggar_OPTIONS
	case beg
	case stand
	case dealer_OPTIONS
	case take_ONE
	case redeal_ANIMATION
	case redeal
	case round_START
	case round_END
	case sub_START
	case sub_END
	case play
	case game_END
	
	func getClass() -> State {
		switch self {
			case .suspend: return SuspendState()
            case .start: return StartState()
			case .first_JACK: return FirstJackState()
			case .first_DEAL: return FirstDealState()
			case .first_DEAL_ANIMATION: return FirstDealAnimationState()
			case .beggar_OPTIONS: return BeggarOptionsState()
			case .beg: return BegState()
			case .stand: return StandState()
			case .dealer_OPTIONS: return DealerOptionsState()
			case .take_ONE: return TakeOneState()
			case .redeal_ANIMATION: return ReDealAnimationState()
			case .redeal: return ReDealState()
			case .round_START: return RoundStartState()
			case .round_END: return RoundEndState()
			case .sub_START: return SubStartState()
			case .sub_END: return SubEndState()
			case .play: return PlayState()
			case .game_END: return GameEndState()
		}
	}
}

protocol State {
	var name: StateName { get }
	
	func toQueue(QDictionary:[StateName:State])
	
	func update() -> Bool
	
	func start()
	
	func onEnter()
	
	func onExit()
	
	func pause()
	
	func resume()
}
