//
//  KeyboardToggleButton.swift
//  Karmies
//
//  Created by Robert Nelson on 14/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

import UIKit


class KeyboardToggleButton: UIButton {

    enum ToggleState {

        case Emoji
        case Keyboard
        
    }

    private var _toggleState: ToggleState
    var toggleState: ToggleState {
        get {
            return _toggleState
        }
        set(value) {
            _toggleState = value
            setImage(KeyboardToggleButton.imageForToggleState(_toggleState), forState: .Normal)
        }
    }

    init(toggleState: ToggleState) {
        _toggleState = toggleState

        super.init(frame: CGRectZero)

        self.toggleState = toggleState
        
        contentMode = UIViewContentMode.Center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func imageForToggleState(toggleState: ToggleState) -> UIImage {
        struct Static {
            static let imageFileNames = [
                ToggleState.Emoji: "EmojiKeyboard_EmojiIcon",
                ToggleState.Keyboard: "EmojiKeyboard_KeyboardIcon",
            ]
        }
        return UIImage.krm_imageNamed(Static.imageFileNames[toggleState]!)!
    }

}
