//
//  InteractiveFeatureViewController.swift
//  Karmies
//
//  Created by Robert Nelson on 18/07/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

import WebKit


class InteractiveFeatureViewController: WebViewController, PSMAdViewDelegate, PSMInterstitialAdDelegate {

    typealias CompletionHandler = (String) -> Void
    
    unowned let context: KarmiesContext
    let emoji: Emoji
    let mode: Emoji.Mode
    private let completionHandler: CompletionHandler?
    
    var bannerAdView: PSMAdView?
    var interstitialAd: PSMInterstitialAd?
    
    init(context: KarmiesContext, emoji: Emoji, mode: Emoji.Mode, completionHandler: CompletionHandler?) {
        self.context = context
        self.emoji = emoji
        self.mode = mode
        self.completionHandler = completionHandler
        
        super.init(url: emoji.URL(mode: mode, additionalParams: context.analyticsParams))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        bannerAdView?.startAndRequestAd()
        interstitialAd?.requestAdWithPlacementName(emoji.adInterstitialId)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        bannerAdView?.stop()
    }
    
    override func publishShellToken(withData data: [String : String]) {
        karmiesLog("begin with \(data)")
        
        if let link = data["link"], url = NSURL(string: link) {
            KRMUtils.openURL(url)
        }
        else if let token = data["token"] {
            completionHandler?(token)

            if interstitialAd != nil && interstitialAd!.isAdReadyForPlacementName(emoji.adInterstitialId) {
                interstitialAd!.displayAdWithPlacementName(emoji.adInterstitialId)
            }
            else {
                close()
            }
        }

        karmiesLog("end")
    }
    
    func setupBannerAd() {
        if bannerAdView == nil {
            bannerAdView = {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.delegate = self
                $0.setPlacement(emoji.adBannerId, withAdType: PSMAdTypeBanner)
                bottomPanelView.addSubview($0)
                return $0
            }(PSMAdView(frame: CGRectZero))
            
            let views = [
                "bannerAdView": bannerAdView!,
            ]
            bottomPanelView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[bannerAdView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            bottomPanelView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[bannerAdView(50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        }
    }
    
    func setupInterstitialAd() {
        if interstitialAd == nil {
            interstitialAd = {
                $0.delegate = self
                return $0
            }(PSMInterstitialAd())
        }
    }
    
    // MARK: Pinsight Ad View Delegate
    
    var adTopViewController: UIViewController! {
        return self
    }
    
    func psmAdViewAdSucceeded(psmAdView: PSMAdView!) {
        karmiesLog("")
        
        view.layoutIfNeeded()
        bottomPanelViewHeightContraint.constant = bannerAdView!.bounds.size.height
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func psmAdViewAdFailed(psmAdView: PSMAdView!) {
        karmiesLog("")
    }
    
    func psmInterstitialAdSucceeded(psmInterstitialAd: PSMInterstitialAd!) {
        karmiesLog("")
    }
    
    func psmInterstitialAdFailed(psmInterstitialAd: PSMInterstitialAd!) {
        karmiesLog("")
    }
    
    func psmInterstitialAdInterstitialClosed(psmInterstitialAd: PSMInterstitialAd!) {
        karmiesLog("")
        
        close()
    }
    
}


// MARK: -


class PreviewInteractiveFeatureViewController: InteractiveFeatureViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if mode == .Default {
            setupInterstitialAd()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if mode == .Default {
            emoji.markAsRead()
        }
    }

}


// MARK: -


class EditInteractiveFeatureViewController: InteractiveFeatureViewController {

    init(context: KarmiesContext, emoji: Emoji, completionHandler: CompletionHandler) {
        super.init(context: context, emoji: emoji, mode: .Editable, completionHandler: completionHandler)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setupBannerAd()
    }
    
}
