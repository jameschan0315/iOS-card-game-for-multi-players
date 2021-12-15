//
//  EmojiStorage.swift
//  Karmies
//
//  Created by Robert Nelson on 14/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

class EmojiStorage {
    
    private weak var context: KarmiesContext?

    private(set) var categories: [EmojiCategory]!
    private(set) var emojiNameSet: Set<String>!
    
    let imageCache = EmojiImageCache()
    private var readEmojiPayloads: Set<String>

    init(json: AnyObject, context: KarmiesContext?) {
        self.context = context
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let data = defaults.objectForKey(KarmiesContext.bundleIdentifier + ".EmojiStorage.readEmojiPayloads") as? NSData {
            readEmojiPayloads = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Set<String>
        }
        else {
            readEmojiPayloads = Set<String>()
        }
        
        let entities = json["entities"] as! [AnyObject]
        categories = entities.map { EmojiCategory(json: $0, storage: self) }
        emojiNameSet = Set(categories.map { $0.emojiNames }.flatMap { $0 })
    }

    // MARK: Emojis

    func emojiWithName(name: String) -> Emoji {
        assert(emojiNameSet.contains(name), "Emoji \(name) should be in emoji name set!")
        
        return Emoji(name: name, payload: nil, storage: self)
    }
    
    func emojiWithToken(token: String) -> Emoji? {
        karmiesLog("begin with \(token)")

        var emoji: Emoji?
        if let params = NSURL(string: token)?.krm_fragmentParams() {
            let name = params["emoji"]!
            if emojiNameSet.contains(name) {
                emoji = Emoji(name: name, payload: params["payload"], storage: self)
            }
        }

        karmiesLog("end with \(emoji)")

        return emoji
    }
    
    // MARK: Read emojis
    
    func checkEmojiIfRead(emoji: Emoji) -> Bool {
        assert(emoji.payload != nil, "Emoji without payload can't be checked!")
        
        let payload = emoji.payload!
        return readEmojiPayloads.contains(payload)
    }
    
    func markEmojiAsRead(emoji: Emoji) {
        assert(emoji.payload != nil, "Emoji without payload can't be checked!")
        
        let payload = emoji.payload!
        readEmojiPayloads.insert(payload)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let data = NSKeyedArchiver.archivedDataWithRootObject(readEmojiPayloads)
        defaults.setObject(data, forKey: KarmiesContext.bundleIdentifier + ".EmojiStorage.readEmojiPayloads")
        defaults.synchronize()
        
        context?.notifyControllersEmojiWasMarkedAsRead(emoji)
    }

}