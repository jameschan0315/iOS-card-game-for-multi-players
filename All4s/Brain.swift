//
//  Brain.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/2/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import Foundation

class Brain {
	weak var data: PublicDataDelegate?
	var duckHigh: Bool = true
	let pointsIgnoreThreshold = 2
	
	func setPublicDataDelegate(_ publicDataDelegate: PublicDataDelegate?) {
		self.data = publicDataDelegate
	}
	
	func rand(_ num: Int) -> Int {
		return Int(arc4random_uniform(UInt32(num)))
	}
	
	func getRedealOption(_ hand: Hand, teamIndex: Int) -> Bool {
        if Constants.getTestRedeal() {
            return true
        }
		let trumpCount = hand.trumpCount()
		return data!.getScores()[1 - teamIndex] > 12 ||
			!(
				hand.getHigh() != nil ||
				trumpCount > 3 ||
				(hand.getLow() != nil && trumpCount > 1) ||
				(hand.highTrumpCount() > 2) ||
				hand.surePoints() > 1
			)
	}
	
	func getBeggarOption(_ hand: Hand) -> Bool {
        if Constants.getTestRedeal() {
            return true
        }
		let trumpCount = hand.trumpCount()
		return
			!(
				hand.getHigh() != nil ||
				trumpCount > 2 ||
				(hand.highTrumpCount() > 1) ||
				hand.surePoints() > 0
			)
	}
	
	// entry
	func getPlay(_ hand: Hand) -> Card? {
		guard let currPlay = data!.currRound()?.plays.count else {return followSuit(hand)}
		switch (currPlay) {
		case 0: return getPlay0(hand)
		case 1: return getPlay1(hand)
		case 2: return getPlay2(hand)
		case 3: return getPlay3(hand)
		default: return followSuit(hand)
		}
	}
	
	func getPlay0(_ hand: Hand) -> Card? {
		// Go for Jack!
		//		let roundUtils = data!.getSubgame()
        let jackPlayed = data!.getRounds()!.contains(where: {$0.jackPlayed})
		if !jackPlayed && hand.getJack() == nil && !data!.getKick()!.isJack() {
			if let high = hand.getHigh() {
				return high
			}
			if let killer = jackKiller(hand) {
				return killer
			}
		}
		if let bushSets = hand.getNonTrumpSets() {
			if let lowBushSets = hand.getLowSets(bushSets) {
				// Shed to maximize chances of fattening
				if let singleBushSet = hand.getSingles(lowBushSets) {
					return singleBushSet[0]
				}
				return Array(lowBushSets.values)[0][0]
			}
			if let highBush = hand.getHighSets(bushSets) {
				return hand.getLowest(highBush)[0]
			}
		}
		if let nonJacks = hand.getNonJacks() {
			if let nonTens = hand.getNonTens(nonJacks) {
				return nonTens[rand(nonTens.count)]
			}
			return nonJacks[0]
		}
		return followSuit(hand)
	}
	
	func getPlay1(_ hand: Hand) -> Card? {
		if trumpCalled() {
			if jackOnTable() {
				if let killer = jackKiller(hand) {
					return killer
				}
			} else if !hand.hasJack() && !data!.getKick()!.isJack() {
				// Cover for jack
				if let highTrumps = hand.getHighTrumps() {
					return highTrumps.min()
				}
			}
			if let lowTrumps = hand.getLowTrumps() {
				return lowTrumps.min()
			}
			if let ten = hand.getTen() {
				return ten
			}
			return followSuit(hand)
		}
		if tenOnTable() {
			if let trump = trumpPriority2(hand) {
				return trump
			}
			if let callSuits = hand.getCallSuits() {
				if let highSuits = hand.getHighs(callSuits) {
					return highSuits.max()
				}
			}
		}
            // TODO: Cover ten ONLY if its never been played
		else if let tenCover = coverTen(hand) {
			return tenCover
		}
		if let lows = hand.getLowCallSuits() {
			return lows.max()
		}
		return followSuit(hand)
	}
	
	func getPlay2(_ hand: Hand) -> Card? {
		if jackOnTable() {
			if let trump = jackKiller(hand) {
				return trump
			}
			if let lowTrumps = hand.getLowCallSuits() {
				return lowTrumps.min()
			}
		}
		if tenOnTable() {
			if let trump = trumpPriority2(hand) {
				if !trump.isUnderTrump() {return trump}
			}
			if let callSuits = hand.getCallSuits() {
				if let highSuits = hand.getHighs(callSuits) {
					return highSuits.max()
				}
			}
		}
		if pointsOnTable() > pointsIgnoreThreshold {
			if let trump = trumpPriority3(hand) {
				if !trump.isUnderTrump() {return trump}
			}
		}
		if let tenCover = coverTen(hand) {
			if !tenCover.isTrump() ||
				(tenCover.isTrump() && !tenCover.isUnderTrump())
			{return tenCover}
		}
		if hand.tenSuitCount() == 1 {
			if let trump = trumpPriority2(hand) {
				if trump.isUnderTrump() {return trump}
			}
		}
		if let lowSuits = hand.getLowCallSuits() {
			return lowSuits[rand(lowSuits.count)]
		}
		if let highSuits = hand.getHighCallSuits() {
			return highSuits[rand(highSuits.count)]
		}
		
		return followSuit(hand)
	}
	
	func getPlay3(_ hand: Hand) -> Card? {
		if trumpCalled() {
			if jackOnTable() {
				if let trump = jackKiller(hand) {
					return trump
				}
			}
			if let lowTrumps = hand.getLowCallSuits() {
				return lowTrumps.min()
			}
			return followSuit(hand)
		}
		if winning() {
			print("winning-play3")
			if let jack = hand.getJack() {
				if !jack.isUnderTrump() {return jack}
			}
			if let card = fatten(hand) {
				if !card.isUnderTrump() {return card}
			}
			if let lows = hand.getLowCallSuits() {
				return lows.min()
			}
			if let nonTrumps = hand.getNonTrumps() {
				return nonTrumps.min()
			}
			if let lowTrumps = hand.getLowTrumps() {
				let lowest = lowTrumps.min()!
				if !lowest.isUnderTrump() {return lowest}
			}
			if let tenTrump = hand.getTenTrump() {
				if !tenTrump.isUnderTrump() {return tenTrump}
			}
		} else {
			if jackOnTable() {
				if let trump = jackKiller(hand) {
					if !trump.isUnderTrump() {return trump}
				}
			}
			//			print("bestCard: "+bestCard().desc)
			if let jack = hand.getJack() {
				if !bestCard().isTrump() || bestCard().rank < jack.rank {
					return jack
				}
			}
			let points = pointsOnTable()
			if points > pointsIgnoreThreshold {
				if let betters = hand.getBetters(bestCard()) {
					//					print("betters", betters)
					if let jack = hand.getJack(betters) {
						return jack
					}
					if let ten = hand.getTen(betters) {
						return ten
					}
					return betters.min()
				}
			}
			if let duckers = hand.getDuckers(bestCard()) {
				//				print("duckers", duckers)
				if let lows = hand.getLows(duckers) {
					return duckHigh ? lows.max() : lows.min()
				}
			}
		}
		return followSuit(hand)
	}
	
	func followSuit(_ hand: Hand) -> Card? {
				print("followSuit")
		if let cards = hand.getCallSuits() {
			//			print("getCallSuits")
			if let lowSuits = hand.getLows(cards) {
				//				print("getLows")
				return lowSuits.min()
			}
			if let highSuits = hand.getHighs(cards) {
				//				print("getHighs")
				return highSuits.min()
			}
		} else {
			if let nonTrumps = hand.getNonTrumps() {
				if let lowSuits = hand.getLows(nonTrumps) {
					//					print("getLowNonTrumps")
					return lowSuits.min()
				}
				if let highSuits = hand.getHighs(nonTrumps) {
					//					print("getHighNonTrumps")
					return highSuits.min()
				}
			}
		}
		
		if let trumps = hand.getTrumps() {
						print("getTrumps")
			if let lowTrumps = hand.getLows(trumps) {
				//				print("getLows")
				let lowest = lowTrumps.min()!
				if !lowest.isUnderTrump() {return lowest}
			}
			if let highTrumps = hand.getHighs(trumps) {
				//				print("getHighs")
				let lowest = highTrumps.min()!
				if !lowest.isUnderTrump() {return lowest}
			}
			if let ten = hand.getTen() {
				print("getTen")
				if !ten.isUnderTrump() {return ten}
			}
			
		}
		if let tenCall = hand.getTenCallSuit() {
			 print("getTenCall")
			return tenCall
		}
		if let cards = hand.getCallSuits() {
			return any(cards, downToTrump: hand.downToTrump())
		}
		if let nonTrumpsSet = hand.getNonTrumpSets() {
			 print("getNonTrumpSets")
			let leastSet = hand.getLeastSet(nonTrumpsSet)
			if hand.getTen(leastSet) == nil {
				// print("getTen")
				if let lows = hand.getLows(leastSet) {
					// print("getLows")
					return lows.min()
				}
			}
		}
		if let nonTrumps = hand.getNonTrumps() {
			 print("getNonTrumps")
			if let lows = hand.getLows(nonTrumps) {
				// print("getLows")
				return lows.min()
			}
			if let highs = hand.getHighs(nonTrumps) {
				// print("getHighs")
				return highs.min()
			}
			if let ten = hand.getTen(nonTrumps) {
				// print("getTen")
				return ten
			}
		}
		 print("anyCard")
		return anyCard(hand)
	}
	
	// last resort
	func anyCard(_ hand: Hand) -> Card? {
		return any(hand.getCards(), downToTrump: hand.downToTrump())
	}
	func any(_ cards: [Card], downToTrump: Bool) -> Card? {
		if cards.count < 1 {
			// print("Problem getting card: \(cards)")
			return nil
		}
		let random = cards[rand(cards.count)]
		if downToTrump || !random.isUnderTrump() {return random}
		else {return any(cards, downToTrump: downToTrump)}
	}
	
	//-------------------- Macro Orders ----------------------
	func coverTen(_ hand: Hand) -> Card? {
		// Cover for 10
		if hand.getTenCallSuit() == nil
			&& !data!.currRound()!.tenPlayed
//			&& !data!.currSubGame()!.tenPlayed // TODO - to implement
			&& !tenCovered()
		
		{
			if let callSuits = hand.getCallSuits() {
				if let highSuits = hand.getHighs(callSuits) {
					return highSuits.min()
				}
			}
			if let trump = trumpPriority3(hand) {
				return trump
			}
		}
		return nil
	}
	func fatten(_ hand: Hand) ->Card? {
		if let suits = hand.getCallSuits() {
			if data!.currRound()!.callCard!.isTrump() {
				if let ten = hand.getTen(suits) {
					return ten
				}
				if let lows = hand.getLows(suits) {
					return lows.min()
				}
			}
			if let fat = hand.getHighestPoints(suits) {
				return fat
			}
		}
		else if let nonTrumps = hand.getNonTrumps() {
			if let fat = hand.getHighestPoints(nonTrumps) {
				return fat
			}
		}
		return nil
	}
	
	func jackKiller(_ hand: Hand) ->Card? {
		let killers = hand.cards.filter{$0.isTrump() && $0.rank > 11}
		if killers.count == 0 {return nil}
		return killers.max()
	}
	
	func trumpPriority2(_ hand: Hand) ->Card? {
		guard let totalDealt = data?.getTotalDealt() else {return nil}
		if let trumps = hand.getTrumps() {
			if totalDealt > 6 {
				if let lowTrumps = hand.getLows(trumps) {
					return lowTrumps.max()
				}
			} else {
				if let highTrumps = hand.getHighTrumps() {
					return highTrumps.min()
				}
			}
		}
		return nil
	}
	
	func trumpPriority3(_ hand: Hand) ->Card? {
		if let trumps = hand.getTrumps() {
			if let lowTrumps = hand.getLows(trumps) {
				return lowTrumps.min()
			}
		}
		return nil
	}
	
	func suitPriority1(_ hand: Hand) ->Card? {
		if let callSuits = hand.getCallSuits() {
			if let highSuits = hand.getHighs(callSuits) {
				return highSuits.max()
			}
		}
		return nil
	}
	
	func suitPriority2(_ hand: Hand) ->Card? {
		if let callSuits = hand.getCallSuits() {
			if let highSuits = hand.getHighs(callSuits) {
				return highSuits.min()
			}
		}
		return nil
	}
	
	func keepLow(_ hand: Hand) ->Card? {
		if let lows = hand.getLowCallSuits() {
			return lows.min()
		}
		return nil
	}
	//-----------------------
	
}

