//
//  Emoji.swift
//  Karmies
//
//  Created by Robert Nelson on 14/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

class Emoji: CustomStringConvertible {
    
    struct ImageBuilder {
        
        static let imageRect = CGRectMake(0, 0, 16, 16)
        static let statusRect = CGRectMake(16, 0, 8, 8)
        
        static func imageForEmojiImage(image: UIImage, statusImage: UIImage?) -> UIImage {
            let size: CGSize = {
                if statusImage != nil {
                    return CGSize(width: max(imageRect.origin.x + imageRect.size.width, statusRect.origin.x + statusRect.size.width), height: max(imageRect.origin.y + imageRect.size.height, statusRect.origin.y + statusRect.size.height))
                }
                else {
                    return CGSize(width: imageRect.origin.x + imageRect.size.width, height:imageRect.origin.y + imageRect.size.height)
                }
            }()
            
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            image.drawInRect(imageRect)
            statusImage?.drawInRect(statusRect)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return image
        }
        
    }
    
    enum Mode {
        
        case Editable
        case Sent
        case Default
        
        static func fromString(value: String?) -> Mode? {
            struct Static {
                static let mapping = [
                    "sent": Mode.Sent,
                ]
            }
            
            if let value = value {
                return Static.mapping[value]
            }
            else {
                return nil
            }
        }
        
        func asString() -> String? {
            switch self {
            case .Editable:
                return "editable"
            case .Sent:
                return "sent"
            case .Default:
                return nil
            }
        }
        
    }
    
    unowned let storage: EmojiStorage
    
    let name: String
    let payload: String?
    
    init(name: String, payload: String?, storage: EmojiStorage) {
        self.storage = storage
        
        self.name = name
        self.payload = (payload != "") ? payload : nil
        
        if self.payload == nil {
            _isRead = true
        }
    }
    
    func URL(mode mode: Mode = .Default, additionalParams: [(String, String)]? = nil) -> NSURL {
        var params = [("emoji", name)]
        if let mode = mode.asString() {
            params.append(("mode", mode))
        }
        if let payload = self.payload {
            params.append(("payload", payload))
        }
        if let additionalParams = additionalParams {
            params += additionalParams
        }
        
        return KarmiesAPI.joyURL(withParams: params)
    }
    
    private var _isRead = false
    var isRead: Bool {
        get {
            if !_isRead {
                _isRead = storage.checkEmojiIfRead(self)
            }
            return _isRead
        }
    }
    
    func markAsRead() {
        if !_isRead {
            _isRead = true
            storage.markEmojiAsRead(self)
        }
    }
    
    // MARK: Image
    
    private var imagePath: String {
        get { return "emojis/\(name).png" }
    }
    
    func image() -> UIImage {
        return storage.imageCache.imageForPath(imagePath)!
    }
    
    func asyncImageWithCompletionHandler(completionHandler: EmojiImageCache.CompletionHandler) {
        storage.imageCache.asyncImageForPath(imagePath, completionHandler: completionHandler)
    }
    
    func imageWithStatus(outgoing outgoing: Bool, mode: Mode = .Default) -> UIImage {
        return ImageBuilder.imageForEmojiImage(image(), statusImage: statusImage(outgoing: outgoing, mode: mode))
    }
    
    private func statusImage(outgoing outgoing: Bool, mode: Mode) -> UIImage? {
        var imageName: String?
        
        if outgoing {
            switch mode {
            case .Editable:
                if payload != nil {
                    imageName = "Pending"
                }
                else {
                    imageName = "Receptive"
                }
            case .Sent, .Default:
                if payload != nil {
                    imageName = "Acknowledged"
                }
            }
        }
        else {
            if payload != nil {
                imageName = (!isRead) ? "Pending" : "Acknowledged"
            }
        }
        
        if let imageName = imageName {
            return UIImage.krm_imageNamed("EmojiStatus_\(imageName)")!
        }
        else {
            return nil
        }
    }
    
    // MARK: Pinsight
    
    var adBannerId: String {
        return "karmies\(name)banner"
    }
    
    var adInterstitialId: String {
        return "karmies\(name)interstitial"
    }

    // MARK: Custom String Convertible

    var description: String {
        return "\(self.dynamicType)(name=\(name) payload=\(payload))>"
    }
    
}


// MARK: -


class EmojiCategory: NSObject {
    
    unowned let storage: EmojiStorage
    
    let name: String
    let imagePath: String
    
    let emojiNames: [String]
    
    init(json: AnyObject, storage: EmojiStorage) {
        self.storage = storage
        
        name = json["name"] as! String
        imagePath = (json["image"] as! String).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "/"))
        emojiNames = json["emojis"] as! [String]
    }
    
    // MARK: Image

    func asyncImageWithCompletionHandler(completionHandler: EmojiImageCache.CompletionHandler) {
        storage.imageCache.asyncImageForPath(imagePath, completionHandler: completionHandler)
    }
    
}