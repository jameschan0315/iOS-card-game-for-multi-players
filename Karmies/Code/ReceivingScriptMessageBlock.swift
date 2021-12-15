//
//  ReceivingScriptMessageBlock.swift
//  Karmies
//
//  Created by Robert Nelson on 29/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

import WebKit


@available(iOS 8.0, *)
class ReceivingScriptMessageBlock: NSObject, WKScriptMessageHandler {
    
    typealias ScriptMessageHandler = (message: WKScriptMessage) -> Void
    
    weak var controller: WKUserContentController?
    let names: [String]
    let handler: ScriptMessageHandler
    
    convenience init(controller: WKUserContentController, name: String, handler: ScriptMessageHandler) {
        self.init(controller: controller, names: [name], handler: handler)
    }
    
    init(controller: WKUserContentController, names: [String], handler: ScriptMessageHandler) {
        self.controller = controller
        self.names = names
        self.handler = handler
        super.init()
        
        names.forEach { controller.addScriptMessageHandler(self, name: $0) }
    }
    
    deinit {
        names.forEach { controller?.removeScriptMessageHandlerForName($0) }
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        handler(message: message)
    }
    
}
