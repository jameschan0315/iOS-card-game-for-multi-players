//
//  delegates.swift
//  All4s Lite
//
//  Created by Adrian Bartholomew on 11/11/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation

extension GameViewModel {
    
    
    func setDelegates() {
        //        Q.appDelegate = appDelegate
        Q.gameDelegate = self
        setGameDelegates()
        setRemoteDelegates()
        setSubGameDelegates()
        setPlayerDelegates()
        setScorables()
        setPublicDataDelegates()
    }
    
    func setGameDelegates() {
        guard let states = game?.states else {return}
        game?.players.forEach{$0.gameDelegate = self}
        (states[.suspend] as! SuspendState).setGameDelegate(self)
        (states[.start] as! StartState).setGameDelegate(self)
        (states[.first_JACK] as! FirstJackState).setGameDelegate(self)
        (states[.first_DEAL_ANIMATION] as! FirstDealAnimationState).setGameDelegate(self)
        (states[.first_DEAL] as! FirstDealState).setGameDelegate(self)
        (states[.dealer_OPTIONS] as! DealerOptionsState).setGameDelegate(self)
        (states[.beggar_OPTIONS] as! BeggarOptionsState).setGameDelegate(self)
        (states[.redeal] as! ReDealState).setGameDelegate(self)
        (states[.take_ONE] as! TakeOneState).setGameDelegate(self)
        (states[.round_START] as! RoundStartState).setGameDelegate(self)
        (states[.round_END] as! RoundEndState).setGameDelegate(self)
        (states[.play] as! PlayState).setGameDelegate(self)
        game?.setStateQueues()
    }
    
    func setRemoteDelegates() {
        guard let states = game?.states else {return}
        (states[.suspend] as! SuspendState).setRemoteDelegate(self)
        (states[.start] as! StartState).setRemoteDelegate(self)
        (states[.first_JACK] as! FirstJackState).setRemoteDelegate(self)
        (states[.redeal] as! ReDealState).setRemoteDelegate(self)
        (states[.first_DEAL_ANIMATION] as! FirstDealAnimationState).setRemoteDelegate(self)
        (states[.dealer_OPTIONS] as! DealerOptionsState).setRemoteDelegate(self)
        (states[.beggar_OPTIONS] as! BeggarOptionsState).setRemoteDelegate(self)
        (states[.redeal_ANIMATION] as! ReDealAnimationState).setRemoteDelegate(self)
        (states[.game_END] as! GameEndState).setRemoteDelegate(self)
    }
    
    func setScorables() {
        guard let states = game?.states else {return}
        (states[.first_JACK] as! FirstJackState).setScorable(self)
        (states[.sub_START] as! SubStartState).setScorable(self)
        (states[.round_START] as! RoundStartState).setScorable(self)
        (states[.first_DEAL] as! FirstDealState).setScorable(self)
        (states[.take_ONE] as! TakeOneState).setScorable(self)
        (states[.redeal] as! ReDealState).setScorable(self)
        (states[.round_END] as! RoundEndState).setScorable(self)
        (states[.sub_END] as! SubEndState).setScorable(self)
    }
    
    func setPublicDataDelegates() {
        guard let states = game?.states else {return}
        (states[.beggar_OPTIONS] as! BeggarOptionsState).setPublicDataDelegate(self)
        (states[.dealer_OPTIONS] as! DealerOptionsState).setPublicDataDelegate(self)
        (states[.play] as! PlayState).setPublicDataDelegate(self)
    }
    
    func setSubGameDelegates() {
        guard let states = game?.states else {return}
        (states[.first_JACK] as! FirstJackState).setSubGameDelegate(subGameController)
        (states[.sub_START] as! SubStartState).setSubGameDelegate(subGameController)
        (states[.round_START] as! RoundStartState).setSubGameDelegate(subGameController)
        (states[.first_DEAL] as! FirstDealState).setSubGameDelegate(subGameController)
        (states[.first_DEAL_ANIMATION] as! FirstDealAnimationState).setSubGameDelegate(subGameController)
        (states[.redeal] as! ReDealState).setSubGameDelegate(subGameController)
    }
    
    func setPlayerDelegates() {
        guard let states = game?.states else {return}
        (states[.first_DEAL] as! FirstDealState).setPlayerDelegate(self)
        (states[.beggar_OPTIONS] as! BeggarOptionsState).setPlayerDelegate(self)
        (states[.dealer_OPTIONS] as! DealerOptionsState).setPlayerDelegate(self)
        (states[.redeal] as! ReDealState).setPlayerDelegate(self)
        (states[.take_ONE] as! TakeOneState).setPlayerDelegate(self)
        (states[.stand] as! StandState).setPlayerDelegate(self)
        (states[.beg] as! BegState).setPlayerDelegate(self)
    }

}
