//
//  KarmiesUtils.swift
//  Karmies
//
//  Created by Robert Nelson on 14/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

public class KarmiesUtils: NSObject {
    
    /**
     Creates UIFont object for the CTFont object using name and size.
     */
    public static func UIFontFromCTFont(font: CTFont) -> UIFont {
        karmiesLog("begin with \(font)")
        
        let name = CTFontCopyFullName(font) as String
        let size = CTFontGetSize(font)
        let uiFont = UIFont(name:name, size:size)!
        
        karmiesLog("end with \(uiFont)")
        
        return uiFont
    }
    
    /**
     Modifies UITextView object's text insets and placeholder view to make free space on the left to place button there.
     */
    public static func placeButton(button: UIButton, onLeftOfTextView textView: UITextView, withPlaceholderView placeholderView: UIView? = nil, inSuperview superview: UIView? = nil) {
        karmiesLog("begin with \(button), \(textView), \(placeholderView), \(superview)")
        
        assert(superview != nil || textView.superview != nil, "textView should have non-null superview or you need to provide non-null superview!")
        
        let superview = (superview != nil) ? superview! : textView.superview!
        
        button.frame = CGRect(origin: CGPoint(x: 0, y: textView.frame.origin.y + (textView.bounds.size.height - button.bounds.size.height) / 2), size: button.bounds.size)
        superview.addSubview(button)
        
        let textInsets = textView.textContainerInset
        textView.textContainerInset = UIEdgeInsets(top: textInsets.top, left: textInsets.left + button.bounds.size.width, bottom: textInsets.bottom, right: textInsets.right)
        
        if let placeholderView = placeholderView {
            placeholderView.frame = placeholderView.frame.offsetBy(dx: button.bounds.size.width, dy: 0)
        }
        
        karmiesLog("end")
    }
    
}
