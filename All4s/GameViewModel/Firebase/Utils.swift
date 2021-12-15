//
//  Firebase
//  All4s
//
//  Created by Adrian Bartholomew2 on 10/24/18.
//  Copyright © 2018 GB Soft. All rights reserved.
//

import Foundation
import Firebase

extension GameViewModel {
    
    func JSONEncode(_ jsonDictionary: [String : Any]) -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
            return String(data: data, encoding: String.Encoding.utf8) ?? ""
        } catch {
            return ""
        }
    }
    
    func JSONDecode(_ str: String) -> Any {
        let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return []
        }
    }
}
