//
//  KarmiesController.swift
//  Karmies
//
//  Created by Robert Nelson on 3/31/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

public class KarmiesController: UIViewController  {

    enum InputView {

        case TextField(UITextField)
        case TextView(UITextView)

        func asView() -> UIView {
            switch self {
            case .TextField(let textField):
                return textField
            case .TextView(let textView):
                return textView
            }
        }

    }
    
    class InputTextViewDelegate: KRMProxyDelegate, UITextViewDelegate {
        
        unowned let krm_controller: KarmiesController
        var krm_textViewDelegate: UITextViewDelegate? {
            get { return krm_delegate as? UITextViewDelegate }
        }
        
        init(controller: KarmiesController, delegate: AnyObject?) {
            krm_controller = controller
            
            super.init(delegate: delegate)
        }
        
        func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
            textView.typingAttributes.removeValueForKey(NSLinkAttributeName)
            
            if let result = krm_textViewDelegate?.textView?(textView, shouldChangeTextInRange: range, replacementText: text) {
                return result
            }
            else {
                return true
            }
        }
        
        func textViewDidChange(textView: UITextView) {
            if krm_controller.inputViewMode == .CoverHost && textView == krm_controller.inputTextView {
                let serializedMessage = krm_controller.context.serializeMessageFromAttributedString(textView.attributedText)
                switch krm_controller.hostInputView {
                case .TextField(let hostInputTextField):
                    hostInputTextField.text = serializedMessage
                case .TextView(let hostInputTextView):
                    hostInputTextView.text = serializedMessage
                }
            }
            
            krm_textViewDelegate?.textViewDidChange?(textView)
        }

    }
    
    class InputTextViewGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
        
        func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
    }
    
    class MessageTextViewDelegate: NSObject, UITextViewDelegate {
        
        unowned let controller: KarmiesController
        
        init(controller: KarmiesController) {
            self.controller = controller
        }
        
        func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
            if controller.context.isSerializedMessage(URL.absoluteString) {
                if let _ = controller.context.emojiStorage.emojiWithToken(URL.absoluteString) {
                    controller.context.presentPreviewSecretMessageControllerForEmojiWithURL(URL)
                    return false
                }
            }
            return true
        }
        
    }
    
    public typealias MessageWasChangedHandler = (forced: Bool) -> Void

    unowned let context: KarmiesContext

    let inputViewMode: KarmiesInputViewMode
	let hostInputView: InputView
    
    let inputTextView: UITextView
    var inputTextViewDelegate: InputTextViewDelegate!
    var inputTextViewGestureRecognizerDelegate: InputTextViewGestureRecognizerDelegate!
    
    var messageTextViewDelegate: MessageTextViewDelegate!

    private var inputTextViewObservers: [KeyPathObservingBlock]!
    private var hostInputViewObservers: [KeyPathObservingBlock]!
    private var hostMessageViewObservers = [KeyPathObservingBlock]()

    let keyboardView: KeyboardView
    private var _keyboardToggleButton: KeyboardToggleButton!
    public var keyboardToggleButton: UIButton {
        get { return _keyboardToggleButton }
    }
    
    public var messageWasChangedHandler: MessageWasChangedHandler?
    
    /**
     Returns a newly initalized Karmies controller.
     - Parameter context: A KarmiesContext object.
     - Parameter hostInputTextField: Host app's UITextField object that should be covered.
     - Returns: A newly initialized KarmiesController object.
     */
	public init(context: KarmiesContext, hostInputTextField: UITextField) {
        self.context = context
		hostInputView = InputView.TextField(hostInputTextField)

        inputViewMode = .CoverHost
        inputTextView = KarmiesController.createInputTextViewForHostInputView(hostInputView)

        keyboardView = KeyboardView(height: 216, context: context)

		super.init(nibName: nil, bundle:nil)

		initialize()
	}
	
    /**
     Returns a newly initalized Karmies controller.
     - Parameter context: A KarmiesContext object.
     - Parameter hostInputTextView: Host app's UITextView object that should be used.
     - Returns: A newly initialized KarmiesController object.
     */
    public init(context: KarmiesContext, hostInputTextView: UITextView) {
        self.context = context
		hostInputView = InputView.TextView(hostInputTextView)

        self.inputViewMode = .UseHost
        switch inputViewMode {
        case .UseHost:
            inputTextView = hostInputTextView
        case .CoverHost:
            inputTextView = KarmiesController.createInputTextViewForHostInputView(hostInputView)
        }

        keyboardView = KeyboardView(height: 216, context: context)

		super.init(nibName: nil, bundle:nil)

		initialize()
	}
    
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func initialize() {
        context.registerController(self)
        
        registerHostInputView()
        setupInputTextView()
		createKeyboardToggleButton()

        view = keyboardView
        keyboardView.backspaceButton.addTarget(self, action: #selector(KarmiesController.backspaceButtonTapped), forControlEvents: .TouchUpInside)
        if context.emojiStorage != nil {
            emojiStorageWasInitialized()
        }
        keyboardView.emojiWasTappedHandler = { [unowned self] name in
            self.addToInputViewEmoji(named: name)
        }
        
        messageTextViewDelegate = MessageTextViewDelegate(controller: self)
        reachabilityWasChanged()
	}
    
    deinit {
        context.unregisterController(self)
        
        inputTextViewObservers = nil
    }

    func emojiStorageWasInitialized() {
        keyboardView.setEmojiStorage(context.emojiStorage)
    }
    
    func reachabilityWasChanged() {
        keyboardView.ReachabilityViewIsHidden = context.isReachable
    }
    
    // MARK: Host message view
	
    /**
     Registers UITextView object as message view to deserialize message from text property every time it's changed.
     */
	public func registerMessageTextView(textView: UITextView) {
        setupMessageTextView(textView)
        
        hostMessageViewObservers.append(KeyPathObservingBlock(object: textView, keyPath: "text", handler: { [unowned self] (object, change) in
            guard !self.inputTextView.text.krm_trimming().isEmpty else {
                return
            }
            if (change?[NSKeyValueChangeNewKey] as? String) != nil {
                let textView = object as! UITextView
                let font = textView.font
                let textColor = textView.textColor
                textView.attributedText = self.inputTextView.attributedText
                textView.font = font
                textView.textColor = textColor
            }
        }))
	}
    
    /**
     Registers UILabel object as message view to deserialize message from text property every time it's changed.
     */
    public func registerMessageLabel(label: UILabel) {
        hostMessageViewObservers.append(KeyPathObservingBlock(object: label, keyPath: "text", handler: { [unowned self] (object, change) in
            guard !self.inputTextView.text.krm_trimming().isEmpty else {
                return
            }
            let label = object as! UILabel
            let font = label.font
            let textColor = label.textColor
            
            let attributedText = NSMutableAttributedString(attributedString: self.inputTextView.attributedText)
            attributedText.addAttributes([
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: textColor,
                ], range: NSMakeRange(0, attributedText.length))
            label.attributedText = attributedText
            label.sizeToFit()
            label.hidden = true
            
            let textViewTag = 45666
            var textView: UITextView! = label.superview!.viewWithTag(textViewTag) as? UITextView
            if textView == nil {
                textView = UITextView()
                textView.textContainerInset = UIEdgeInsetsZero
                textView.textContainer.lineFragmentPadding = 0
                self.setupMessageTextView(textView)
                
                label.superview!.addSubview(textView)
            }
            textView.frame = label.frame
            
            textView.attributedText = attributedText
            textView.backgroundColor = UIColor.clearColor()
        }))
    }
    
    /**
     Unregisters UIView object as message view.
     */
    public func unregisterMessageView(view: UIView) {
        hostMessageViewObservers = hostMessageViewObservers.filter { $0.object != view }
    }
    
    private func setupMessageTextView(textView: UITextView) {
        textView.delegate = messageTextViewDelegate
        textView.editable = false
        textView.selectable = true
        textView.dataDetectorTypes = UIDataDetectorTypes.Link
    }
    
    // MARK: Host input view
    
    private func registerHostInputView() {
        if inputViewMode == .CoverHost {
            let hostView = hostInputView.asView()
            
            hostInputViewObservers = [
                KeyPathObservingBlock(object: hostView, keyPath: "text", handler: { [unowned self] _, change in
                    if let text = change?[NSKeyValueChangeNewKey] as? String {
                        if text.isEmpty {
                            self.inputTextView.text = ""
                        }
                    }
                }),
            ]
        }
    }
    
    private static func createInputTextViewForHostInputView(hostInputView: InputView) -> UITextView {
        let hostView = hostInputView.asView()
        hostView.hidden = true
        
        let wrapperView = UIView(frame: CGRect(origin: hostView.frame.origin, size: hostView.frame.size))
        
        let inputTextView = UITextView(frame: CGRect(x:0, y:0, width:wrapperView.frame.width, height:wrapperView.frame.height))
        inputTextView.backgroundColor = UIColor.clearColor()
        wrapperView.backgroundColor = hostView.backgroundColor
        wrapperView.layer.borderColor = UIColor(white: 1, alpha: 0.2).CGColor
        wrapperView.layer.borderWidth = 1.0
        wrapperView.layer.cornerRadius = 3.0
        switch hostInputView {
        case .TextField(let hostInputTextField):
            inputTextView.font = hostInputTextField.font
            inputTextView.textColor = hostInputTextField.textColor
        case .TextView(let hostInputTextView):
            inputTextView.font = hostInputTextView.font
            inputTextView.textColor = hostInputTextView.textColor
        }
        
        wrapperView.addSubview(inputTextView)
        hostView.superview!.addSubview(wrapperView)
        
        return inputTextView
    }
    
    // MARK: Input text view
    
    private func setupInputTextView() {
        inputTextViewDelegate = InputTextViewDelegate(controller: self, delegate: self.inputTextView.delegate)
        inputTextView.delegate = inputTextViewDelegate
        
        inputTextViewGestureRecognizerDelegate = InputTextViewGestureRecognizerDelegate()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(inputTextViewTapped))
        tapRecognizer.delegate = inputTextViewGestureRecognizerDelegate
        inputTextView.addGestureRecognizer(tapRecognizer)
        
        inputTextViewObservers = [
            KeyPathObservingBlock(object: inputTextView, keyPath: "inputView", handler: { [unowned self] _, _ in
                self.updateKeyboardToggleButtonState()
            }),
            KeyPathObservingBlock(object: inputTextView, keyPath: "delegate", handler: { [unowned self] object, _ in
                if self.inputTextView.delegate == nil || !self.inputTextView.delegate!.isKindOfClass(InputTextViewDelegate) {
                    self.inputTextViewDelegate = InputTextViewDelegate(controller: self, delegate: self.inputTextView.delegate)
                    self.inputTextView.delegate = self.inputTextViewDelegate
                }
            }),
        ]
    }
    
    private func addToInputViewEmoji(named name: String) {
        let emoji = context.emojiStorage.emojiWithName(name)
        let emojiString = context.attributedStringForEmoji(emoji, outgoing: true, mode: .Editable, attributes: inputTextView.typingAttributes)
        
        inputTextView.textStorage.replaceCharactersInRange(inputTextView.selectedRange, withAttributedString: emojiString)
        inputTextView.delegate?.textViewDidChange!(inputTextView)
        inputTextView.selectedRange = NSMakeRange(inputTextView.selectedRange.location + emojiString.length, 0)
        inputTextView.typingAttributes.removeValueForKey(NSLinkAttributeName)
        
        if inputViewMode == .CoverHost {
            switch hostInputView {
            case .TextField(let hostInputTextField):
                inputTextView.font = hostInputTextField.font
                inputTextView.textColor = hostInputTextField.textColor
            case .TextView(let hostInputTextView):
                inputTextView.font = hostInputTextView.font
                inputTextView.textColor = hostInputTextView.textColor
            }
        }
    }
    
    func inputTextViewTapped(sender: UITapGestureRecognizer) {
        if sender.view == inputTextView {
            if sender.state == .Ended {
                let point = sender.locationInView(inputTextView)
                if let (token, index, _) = context.linkAtPoint(point, inTextView: inputTextView) {
                    let emoji = context.emojiStorage.emojiWithToken(token)!

                    context.analytics.sendEvent(MessageEmojiAnalyticsEvent(category: .input, action: .click, emojiName: emoji.name, emojiPayload: emoji.payload))

                    context.presentEditSecretMessageControllerForEmoji(emoji) { [unowned self] token in
                        let emoji = self.context.emojiStorage.emojiWithToken(token)!

                        self.context.analytics.sendEvent(MessageEmojiAnalyticsEvent(category: .input, action: .getBack, emojiName: emoji.name, emojiPayload: emoji.payload))

                        let emojiString = self.context.attributedStringForEmoji(emoji, outgoing: true, mode: .Editable, attributes: self.inputTextView.typingAttributes)
                        self.inputTextView.textStorage.replaceCharactersInRange(NSMakeRange(index, 1), withAttributedString: emojiString)
                    }
                }
            }
        }
    }

    // MARK: Keyboard toggle button

    private func createKeyboardToggleButton() {
        let button = KeyboardToggleButton(toggleState: .Emoji)

        button.addTarget(self, action: #selector(KarmiesController.keyboardToggleButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        let x = inputTextView.frame.origin.x + 5
        let y = inputTextView.frame.origin.y
        let h = inputTextView.frame.height
        button.frame = CGRectMake(x, y, h, h)
        
        _keyboardToggleButton = button
    }

    private func updateKeyboardToggleButtonState() {
        if inputTextView.inputView != view {
            context.analytics.sendEvent(KeyboardAnalyticsEvent(action: .close))

            _keyboardToggleButton.toggleState = .Emoji
        }
        else {
            context.analytics.sendEvent(KeyboardAnalyticsEvent(action: .open))

            _keyboardToggleButton.toggleState = .Keyboard
        }
    }

    func keyboardToggleButtonTapped(sender: NSObject) {
        inputTextView.resignFirstResponder()
        if inputTextView.inputView != view {
            inputTextView.inputView = view
        }
        else {
            inputTextView.inputView = nil
        }
        inputTextView.reloadInputViews()
        inputTextView.becomeFirstResponder()
    }

    // MARK: Backspace button
    
    func backspaceButtonTapped(button: UIButton) {
        inputTextView.deleteBackward()
    }

}


// MARK: -


@objc
public enum KarmiesInputViewMode: Int {

    case UseHost
    case CoverHost
    
}
