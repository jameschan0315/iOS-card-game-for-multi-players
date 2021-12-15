//
//  WebViewController.swift
//  Karmies
//
//  Created by Robert Nelson on 29/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

import WebKit


class WebViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate, ReplacingRootViewController {
    
    var krm_previousRootViewController: UIViewController?
    
    private let url: NSURL!
    
    private(set) var webView: UIView!
    
    private(set) var bottomPanelView: UIView!
    private(set) var bottomPanelViewHeightContraint: NSLayoutConstraint!
    
    private var receivingScriptMessageHandlers = [AnyObject]()
    
    init(url: NSURL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        loadInWebView(url)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: Views
    
    private func setupViews() {
        view.backgroundColor = UIColor.whiteColor()
        
        webView = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
            return $0
        }(webView(useWebKit: true))
        
        bottomPanelView = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
            return $0
        }(UIView())
        
        let views = [
            "webView": webView,
            "bottomPanelView": bottomPanelView,
        ]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[webView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[bottomPanelView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[webView]-0-[bottomPanelView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        bottomPanelViewHeightContraint = NSLayoutConstraint(item: bottomPanelView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
        view.addConstraint(bottomPanelViewHeightContraint)
    }
    
    private func webView(useWebKit useWebKit: Bool) -> UIView {
        if useWebKit {
            if #available(iOS 8.0, *) {
                let configuration = WKWebViewConfiguration()
                
                let controller = WKUserContentController()
                receivingScriptMessageHandlers.append(ReceivingScriptMessageBlock(controller: controller, name: "publishShellToken", handler: { [weak self] message in
                    self?.publishShellToken(withData: message.body as! [String: String])
                }))
                configuration.userContentController = controller
                
                return {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    $0.navigationDelegate = self
                    return $0
                }(WKWebView(frame: CGRectZero, configuration: configuration))
            }
        }
        
        return {
            $0.delegate = self
            return $0
        }(UIWebView(frame: CGRectZero))
    }
    
    private func loadInWebView(url: NSURL) {
        let request = NSURLRequest(URL: url)
        
        if #available(iOS 8.0, *) {
            if let webView = webView as? WKWebView {
                webView.loadRequest(request)
            }
        }
        if let webView = webView as? UIWebView {
            webView.loadRequest(request)
        }
    }
    
    private func currentPositionScript(with location: CLLocation) -> String {
        return [
            "window.navigator.geolocation.getCurrentPosition = function(success) {",
            "   success({",
            "       coords: {",
            "           latitude: \(location.coordinate.latitude),",
            "           longitude: \(location.coordinate.longitude),",
            "           accuracy: \(location.horizontalAccuracy),",
            "       },",
            "       timestamp: \(location.timestamp.timeIntervalSinceReferenceDate * 1000)",
            "   });",
            "};",
        ].joinWithSeparator("\n")
    }

    // MARK: Navigation Delegate
    
    @available(iOS 8.0, *)
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        webView.evaluateJavaScript([
            "window.parent.postMessage = function(data) {",
            "   window.webkit.messageHandlers.publishShellToken.postMessage(data);",
            "};",
        ].joinWithSeparator("\n"), completionHandler: nil)
        
        if let location = KarmiesContext.sharedInstance.locationManager.currentLocation {
            webView.evaluateJavaScript(currentPositionScript(with: location), completionHandler: nil)
        }
    }
    
    // MARK: Web View Delegate
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString([
            "window.parent.postMessage = function(data) {",
            "   var iframe = document.createElement('IFRAME');",
            "   iframe.setAttribute('src', 'postmessage://publishshelltoken/' + encodeURIComponent(JSON.stringify(data)));",
            "   document.documentElement.appendChild(iframe);",
            "   iframe.parentNode.removeChild(iframe);",
            "   iframe = null;",
            "};",
        ].joinWithSeparator("\n"))
        
        if let location = KarmiesContext.sharedInstance.locationManager.currentLocation {
            webView.stringByEvaluatingJavaScriptFromString(currentPositionScript(with: location))
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.URL {
            if url.scheme == "postmessage" {
                if url.host == "publishshelltoken" {
                    let dataString = url.path!.substringFromIndex(url.path!.startIndex.successor())
                    let data = try! NSJSONSerialization.JSONObjectWithData(dataString.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)
                    publishShellToken(withData: data as! [String: String])
                }
                return false
            }
        }
        return true
    }
    
    // MARK: Actions
    
    func publishShellToken(withData data: [String: String]) {
    }
    
    func close() {
        if navigationController != nil {
            navigationController?.popViewControllerAnimated(true)
        }
        else {
            krm_dismissAndRestoreRootViewController()
        }
    }
    
}