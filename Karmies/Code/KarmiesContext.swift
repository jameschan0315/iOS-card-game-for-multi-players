//
//  KarmiesContext.swift
//  Karmies
//
//  Created by Robert Nelson on 14/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

public class KarmiesContext: NSObject {
    
    private static var _sharedInstance: KarmiesContext?
    
    static let bundleIdentifier = "com.karmies.joy.Karmies"
    static let googleAnalyticsTrackingID = "UA-77165978-1" // "UA-79765045-1"
    
    private static let emojiRegex = try! NSRegularExpression(pattern: "\\s?\(KarmiesAPI.joyPrefixURLString)[^\\s]*\\s?", options: NSRegularExpressionOptions(rawValue: 0))

    static var resourceBundle: NSBundle {
        get {
            var bundle: NSBundle!
            if #available(iOS 8.0, *) {
                bundle = NSBundle(identifier: KarmiesContext.bundleIdentifier)
                assert(bundle != nil, "Bundle \(KarmiesContext.bundleIdentifier) should be presented!")
            }
            else {
                if let path = NSBundle.mainBundle().pathForResource("KarmiesResources", ofType: "bundle") {
                    bundle = NSBundle(path: path)
                }
                else {
                    fatalError("Bundle KarmiesResources should be presented!")
                }
            }
            return bundle!
        }
    }
    
    let clientID: String
    private(set) var emojiStorage: EmojiStorage!
    let analytics: AnalyticsManager
    let locationManager = LocationManager()
    
    private var registeredControllers = [WeakWrapper<KarmiesController>]()
    private var reachabilityObserver: ReachabilityObserver!
    
    private(set) var isReachable = false
    private var isUpdated = false
    
    init(publisherID: String) {
        KarmiesContext.logVersion()
        
        self.clientID = publisherID
        self.analytics = AnalyticsManager(clientID: clientID)
        super.init()
        
        PSMAdManager.startWithApplicationId(publisherID)
        AnalyticsManager.setup()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let data = defaults.objectForKey(KarmiesContext.bundleIdentifier + ".EmojiContext.emojiStorageJson") as? NSData, json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) {
            initEmojiStorage(withJson: json)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.reachabilityWasChanged), name: ReachabilityObserver.ReachabilityWasChangedNotificationName, object: nil)
        
        reachabilityObserver = ReachabilityObserver(url: KarmiesAPI.grimacingCategoriesURL(withClientID: publisherID))
        isReachable = reachabilityObserver.isReachable
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Emoji storage
    
    private func initEmojiStorage(withClientID clientID: String) {
        karmiesLog("begin with \(clientID)")

        locationManager.updateLocation { [unowned self] location in
            var params = [
                ("agent", self.analytics.agentID),
            ]
            if let coordinate = self.locationManager.currentLocation?.coordinate {
                params += [
                    ("latitude", coordinate.latitude.description),
                    ("longitude", coordinate.longitude.description),
                ]
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                do {
                    let data = try NSData(contentsOfURL: KarmiesAPI.grimacingCategoriesURL(withClientID: clientID, params: params), options: NSDataReadingOptions(rawValue: 0))
                    assert(NSString(data:data, encoding:NSUTF8StringEncoding) != nil, "Data should be a string!")
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(data, forKey: KarmiesContext.bundleIdentifier + ".EmojiContext.emojiStorageJson")
                    defaults.synchronize()

                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.initEmojiStorage(withJson: json)
                        self.isUpdated = true
                    }
                }
                catch let error as NSError {
                    karmiesLog("\(error.localizedDescription)")
                }
            }
        }

        karmiesLog("end with \(emojiStorage)")
    }
    
    func initEmojiStorage(withJson json: AnyObject) {
        self.emojiStorage = EmojiStorage(json: json, context: self)
        
        self.notifyControllersEmojiStorageWasInitialized()
        self.notifyControllersMessageWasChanged(forced: true)
    }
    
    // MARK: Message
    
    /**
     Returns serialized message for the attributed text.
     */
    public func serializeMessageFromAttributedString(attributedText: NSAttributedString) -> String {
        karmiesLog("begin with \(attributedText)")
        
        var serializedString = ""
        var prevLink = false
        
        attributedText.enumerateAttribute(NSLinkAttributeName, inRange: NSMakeRange(0, attributedText.length), options: NSAttributedStringEnumerationOptions.init(rawValue: 0)) { value, range, stop in
            if let link = value as? String {
                for _ in 0..<range.length {
                    if !serializedString.isEmpty {
                        serializedString += " "
                    }
                    serializedString += link + " "
                }
                prevLink = true
            }
            else {
                let text = attributedText.attributedSubstringFromRange(range).string
                serializedString += text
                prevLink = false
            }
        }
        if prevLink {
            serializedString = serializedString.substringToIndex(serializedString.endIndex.predecessor())
        }
        
        karmiesLog("end with \(serializedString)")
        
        return serializedString
    }
    
    func deserializeMessage(message: String, outgoing: Bool) -> NSAttributedString {
        karmiesLog("begin with \(message), \(outgoing)")
        
        var message = message
        let desezializedMessage = NSMutableAttributedString()
        
        while message.krm_length > 0 {
            if let range = KarmiesContext.emojiRegex.firstMatchInString(message, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, message.krm_length))?.range {
                let startIndex = message.startIndex.advancedBy(range.location)
                let endIndex = startIndex.advancedBy(range.length)
                if startIndex != message.startIndex {
                    desezializedMessage.appendAttributedString(NSAttributedString(string: message.substringToIndex(startIndex)))
                }
                
                let token = message.substringWithRange(startIndex..<endIndex)
                if let emoji = emojiStorage.emojiWithToken(token.krm_trimmingWhitespaces()) {
                    let emojiString = attributedStringForEmoji(emoji, outgoing: outgoing, mode: .Default, attributes: nil)
                    desezializedMessage.appendAttributedString(emojiString)
                }
                else {
                    desezializedMessage.appendAttributedString(NSAttributedString(string: token))
                }
                
                message = message.substringFromIndex(endIndex)
            }
            else {
                desezializedMessage.appendAttributedString(NSAttributedString(string: message))
                message = ""
            }
        }
        
        karmiesLog("end with \(desezializedMessage)")
        
        return desezializedMessage
    }

    /**
     Checks if the message contains serialized emojis.
     */
    public func isSerializedMessage(message: String) -> Bool {
        karmiesLog("begin with \(message)")

        if emojiStorage == nil {
            karmiesLog("emoji storage isn't initialized")

            return false
        }
        
        var result = false
        KarmiesContext.emojiRegex.enumerateMatchesInString(message, options: NSMatchingOptions(rawValue: 0), range: message.krm_fullRange(), usingBlock: { [unowned self] matchResult, flags, stop in
            if let range = matchResult?.range {
                let token = message.krm_substring(withRange: range)
                if let _ = self.emojiStorage.emojiWithToken(token.krm_trimmingWhitespaces()) {
                    result = true
                    stop.memory = true
                }
            }
        })
        
        karmiesLog("end with \(result)")
        
        return result
    }
    
    /**
     Returns size of message after deserialization with the according parameters.
     - Parameter message: The serialized message.
     - Parameter outgoing: Is the message is outgoing/ingoing.
     - Parameter font: The font for deserialized message.
     - Parameter maxWidth: Maximum width of deserialized message.
     - Returns: The size of deserialized message.
     */
    public func measureSerializedMessage(message: String, outgoing: Bool, font: UIFont, maxWidth: CGFloat) -> CGSize {
        karmiesLog("begin with \(message), \(outgoing), \(font), \(maxWidth)")
        
        var size: CGSize!
        let calculationClosure = { [unowned self] in
            let textView = self.reusableTextViewForMessage(message, outgoing: outgoing, font: font)
            karmiesLog("text view \(textView)")
            size = textView.sizeThatFits(CGSize(width: maxWidth, height: 0))
        }
        
        if NSThread.isMainThread() {
            karmiesLog("on main thread")
            calculationClosure()
        }
        else {
            karmiesLog("not on main thread")
            dispatch_sync(dispatch_get_main_queue(), calculationClosure)
        }
        
        karmiesLog("end with \(size)")
        
        return size
    }

    /**
     Draws the message with according parameters inside the frame.
     - Parameter message: The serialized message.
     - Parameter outgoing: Is the message is outgoing/ingoing.
     - Parameter frame: The frame where the message will be drawn.
     - Parameter font: The font for the message.
     */
    public func drawSerializedMessage(message: String, outgoing: Bool, insideFrame frame: CGRect, withFont font: UIFont) {
        karmiesLog("begin with \(message), \(outgoing), \(frame), \(font)")
        
        let context = UIGraphicsGetCurrentContext()!
        CGContextSaveGState(context)
        
        let textView = reusableTextViewForMessage(message, outgoing: outgoing, font: font)
        textView.frame = frame
        textView.layer.renderInContext(context)
        
        CGContextRestoreGState(context)
        
        karmiesLog("end")
    }

    /**
     Returns the link from the message at the point if it's presented
     - Parameter point: The point inside the message frame.
     - Parameter frame: The message frame.
     - Parameter message: The serialized message.
     - Parameter outgoing: Is the message is outgoing/ingoing.
     - Parameter font: The font for the message.
     - Returns: The link if it's presented or nil.
     */
    public func linkAtPoint(point: CGPoint, insideFrame frame: CGRect, withSerializedMessage message: String, outgoing: Bool, font: UIFont) -> String? {
        karmiesLog("begin with \(point), \(frame), \(message), \(outgoing), \(font)")
        
        let textView = reusableTextViewForMessage(message, outgoing: outgoing, font: font)
        textView.frame = frame
        
        var resultLink: String?
        if let (link, _, _) = linkAtPoint(point, inTextView: textView) {
            let emoji = emojiStorage.emojiWithToken(link)
            let mode: Emoji.Mode = (outgoing) ? .Sent : .Default
            resultLink = emoji?.URL(mode: mode).absoluteString
        }
        
        karmiesLog("end with \(resultLink)")
        
        return resultLink
    }
    
    func linkAtPoint(point: CGPoint, inTextView textView: UITextView) -> (String, Int, CGRect)? {
        if textView.textStorage.length > 0 {
            let point = CGPoint(x: point.x - textView.textContainerInset.left, y: point.y - textView.textContainerInset.top)
            let index = textView.layoutManager.characterIndexForPoint(point, inTextContainer: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            let glyphRect = textView.layoutManager.boundingRectForGlyphRange(NSMakeRange(index, 1), inTextContainer: textView.textContainer)
            
            if CGRectContainsPoint(glyphRect, point) {
                let range: NSRangePointer = nil
                let attributes = textView.textStorage.attributesAtIndex(index, effectiveRange: range)
                if let _ = attributes[NSAttachmentAttributeName] as? NSTextAttachment {
                    return (attributes[NSLinkAttributeName] as! String, index, glyphRect)
                }
            }
        }
        return nil
    }
    
    func attributedStringForEmoji(emoji: Emoji, outgoing: Bool, mode: Emoji.Mode, attributes: [String: AnyObject]?) -> NSAttributedString {
        karmiesLog("begin with \(emoji), \(outgoing), \(attributes)")
        
        let attachment: NSTextAttachment = {
            $0.image = emoji.imageWithStatus(outgoing: outgoing, mode: mode)
            return $0
        }(NSTextAttachment())
        let attributedString: NSAttributedString = {
            var attributes = attributes ?? [String: AnyObject]()
            attributes[NSLinkAttributeName] = emoji.URL().absoluteString
            $0.addAttributes(attributes, range: NSMakeRange(0, $0.length))
            return $0
        }(NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment)))
        
        karmiesLog("end with \(attributedString)")
        
        return attributedString
    }
    
    // MARK: Reusable text view
    
    private var reusableTextView: UITextView!
    
    private func reusableTextViewForMessage(message: String, outgoing: Bool, font: UIFont) -> UITextView {
        if reusableTextView == nil {
            reusableTextView = UITextView(frame: CGRectZero)
            reusableTextView.backgroundColor = UIColor.clearColor()
            reusableTextView.textContainerInset = UIEdgeInsetsZero
            reusableTextView.textContainer.lineFragmentPadding = 0
        }
        
        let attributedText = NSMutableAttributedString(attributedString: deserializeMessage(message, outgoing: outgoing))
        attributedText.addAttributes([
            NSFontAttributeName: font,
        ], range: NSMakeRange(0, attributedText.length))
        reusableTextView.attributedText = attributedText
        
        return reusableTextView
    }
    
    // MARK: Secret Message Controller

    func presentEditSecretMessageControllerForEmoji(emoji: Emoji, completionHandler: (String) -> Void) {
        let controller = EditInteractiveFeatureViewController(context: self, emoji: emoji, completionHandler: completionHandler)
        UIViewController.krm_presentAndReplaceRootViewControllerWithViewController(controller)
    }

    /**
     Present preview interactive feature view for the emoji with specified URL.
     - Parameter url: The url for the emoji.
     */
    public func presentPreviewSecretMessageControllerForEmojiWithURL(url: NSURL) {
        karmiesLog("begin with \(url)")
        
        if let emoji = emojiStorage.emojiWithToken(url.absoluteString) {
            karmiesLog("emoji \(emoji)")
            
            let params = url.krm_fragmentParams()
            let mode = Emoji.Mode.fromString(params["mode"]) ?? .Default

            let eventCategory: MessageEmojiAnalyticsEvent.Category = (mode == .Default) ? .received : .sent
            self.analytics.sendEvent(MessageEmojiAnalyticsEvent(category: eventCategory, action: .click, emojiName: emoji.name, emojiPayload: emoji.payload))
            
            let controller = PreviewInteractiveFeatureViewController(context: self, emoji: emoji, mode: mode, completionHandler: { [unowned self] token in
                self.analytics.sendEvent(MessageEmojiAnalyticsEvent(category: eventCategory, action: .getBack, emojiName: emoji.name, emojiPayload: emoji.payload))
            })
            UIViewController.krm_presentAndReplaceRootViewControllerWithViewController(controller)
        }
        
        karmiesLog("end")
    }
    
    // MARK: Pinsight
    
    var pinsightAdManager: PSMAdManager {
        get { return PSMAdManager.sharedInstance() }
    }

    // MARK: Analytics

    var analyticsParams: [(String, String)] {
        get {
            return [
                ("client", clientID),
                ("agent", analytics.agentID),
            ]
        }
    }
    
    // MARK: Controllers
    
    func registerController(controller: KarmiesController) {
        registeredControllers.append(WeakWrapper(value: controller))
    }
    
    func unregisterController(controller: KarmiesController) {
        registeredControllers = registeredControllers.filter { $0.value != nil && $0.value != controller }
    }
    
    func notifyControllersEmojiWasMarkedAsRead(emoji: Emoji) {
        notifyControllersMessageWasChanged()
    }

    func notifyControllersMessageWasChanged(forced forced: Bool = false) {
        registeredControllers.forEach { $0.value?.messageWasChangedHandler?(forced: forced) }
    }

    func notifyControllersEmojiStorageWasInitialized() {
        registeredControllers.forEach { $0.value?.emojiStorageWasInitialized() }
    }
    
    // MARK: Reachability
    
    @objc
    private func reachabilityWasChanged() {
        isReachable = reachabilityObserver.isReachable
        registeredControllers.forEach { $0.value?.reachabilityWasChanged() }
        
        if isReachable && !isUpdated {
            initEmojiStorage(withClientID: clientID)
        }
    }
    
    // MARK: Shared instance

    /**
     Configured shared instance.
     */
    public static var sharedInstance: KarmiesContext {
        get {
            assert(_sharedInstance != nil, "Shared instance should be initialized before using.")

            return _sharedInstance!
        }
    }

    /**
     Configures shared instance with the specified publisher ID.
     - Parameter publisherID: Publisher ID
     - Returns: Configured shared instance.
     */
    public static func initSharedInstance(withPublisherID publisherID: String) -> KarmiesContext {
        karmiesLog("begin with \(publisherID)")
        
        if _sharedInstance == nil || _sharedInstance!.clientID != publisherID {
            _sharedInstance = KarmiesContext(publisherID: publisherID)
        }
        
        karmiesLog("end with \(_sharedInstance)")
        
        return _sharedInstance!
    }
    
}


// MARK: - Debug

extension KarmiesContext {
    
    private static func logVersion() {
        struct Static {
            static var versionInfoDispatchOnce: dispatch_once_t = 0
        }
        dispatch_once(&Static.versionInfoDispatchOnce) {
            if let version = KarmiesContext.resourceBundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as? String, build = KarmiesContext.resourceBundle.objectForInfoDictionaryKey("CFBundleVersion") as? String {
                karmiesLog("SDK version \(version) (\(build))")
            }
            else {
                karmiesLog("can't get SDK version from bundle!")
            }
        }
    }
    
}
