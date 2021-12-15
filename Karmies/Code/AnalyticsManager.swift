//
//  AnalyticsManager.swift
//  Karmies
//
//  Created by Robert Nelson on 22/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

class AnalyticsEvent {

    enum Dimension: Int {

        case client = 1
        case emoji = 2
        case category = 3

    }


    enum Metric: Int {

        case emojiIndex = 1
        case categoryIndex = 2
        case payloadCount = 3
        
    }

    let category: String
    let action: String
    let dimensions: [NSNumber: String]?
    let metrics: [NSNumber: Int]?

    init(category: String, action: String, dimensions: [NSNumber: String]? = nil, metrics: [NSNumber: Int]? = nil) {
        self.category = category
        self.action = action
        self.dimensions = dimensions
        self.metrics = metrics
    }

}


class KeyboardAnalyticsEvent: AnalyticsEvent {

    enum Action: String {

        case open = "open"
        case close = "close"
        
    }

    init(action: Action) {
        super.init(category: "Keyboard", action: action.rawValue)
    }

}


class KeyboardEmojiCategoryAnalyticsEvent: AnalyticsEvent {

    enum Action: String {

        case open = "open"

    }

    init(action: Action, emojiCategoryName: String, emojiCategoryIndex: Int) {
        let dimensions = [
            Dimension.category.rawValue: emojiCategoryName,
        ]
        let metrics = [
            Metric.categoryIndex.rawValue: emojiCategoryIndex,
        ]
        super.init(category: "Keyboard Categories", action: action.rawValue, dimensions: dimensions, metrics: metrics)
    }

}


class KeyboardEmojiAnalyticsEvent: AnalyticsEvent {

    enum Action: String {

        case click = "click"

    }

    init(action: Action, emojiName: String, emojiIndex: Int, emojiCategoryName: String, emojiCategoryIndex: Int) {
        let dimensions = [
            Dimension.emoji.rawValue: emojiName,
            Dimension.category.rawValue: emojiCategoryName,
        ]
        let metrics = [
            Metric.emojiIndex.rawValue: emojiIndex,
            Metric.categoryIndex.rawValue: emojiCategoryIndex,
        ]
        super.init(category: "Keyboard Emojis", action: action.rawValue, dimensions: dimensions, metrics: metrics)
    }
    
}


class MessageEmojiAnalyticsEvent: AnalyticsEvent {

    enum Category: String {

        case input = "Message Input Emojis"
        case sent = "Sent Message Emojis"
        case received = "Received Message Emojis"

    }

    enum Action: String {

        case click = "click"
        case getBack = "return"

    }

    init(category: Category, action: Action, emojiName: String, emojiPayload: String?) {
        let dimensions = [
            Dimension.emoji.rawValue: emojiName,
        ]
        let metrics = [
            Metric.payloadCount.rawValue: (emojiPayload != nil) ? 1 : 0,
        ]
        super.init(category: category.rawValue, action: action.rawValue, dimensions: dimensions, metrics: metrics)
    }

}


class AnalyticsManager {

    var agentID: String {
        return googleAnalytics.clientID
    }
    
    private let googleAnalytics: KRMGoogleAnalytics
    private let clientID: String
    
    init(clientID: String) {
        self.clientID = clientID
        googleAnalytics = KRMGoogleAnalytics(trackingID: KarmiesContext.googleAnalyticsTrackingID, defaultDimensions: [
            AnalyticsEvent.Dimension.client.rawValue: clientID,
        ])
    }

    func sendEvent(event: AnalyticsEvent) {
        googleAnalytics.sendEventWithCategory(event.category, action: event.action, dimensions: event.dimensions, metrics: event.metrics)
    }

    static func setup() {
        KRMGoogleAnalytics.setup()
    }

}
