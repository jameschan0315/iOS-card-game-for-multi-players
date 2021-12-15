//
//  Extensions.swift
//  Karmies
//
//  Created by Robert Nelson on 29/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

extension NSURL {

    func krm_fragmentParams() -> [String: String] {
        var params = [String: String]()
        if let pairs = fragment?.componentsSeparatedByString("&") where pairs.count > 0 {
            for pair in pairs {
                let keyAndValue = pair.componentsSeparatedByString("=")
                params[keyAndValue[0]] = keyAndValue[1]
            }
        }
        return params
    }

}

extension UIImage {
    
    class func krm_imageNamed(name: String) -> UIImage? {
        if #available(iOS 8.0, *) {
            return UIImage(named: name, inBundle: KarmiesContext.resourceBundle, compatibleWithTraitCollection: nil)
        } else {
            if let resourcePath = KarmiesContext.resourceBundle.resourcePath {
                let path = resourcePath + "/\(name)@2x.png"
                return UIImage(contentsOfFile: path)
            }
        }
        return nil
    }

}


extension String {

    var krm_length: Int {
        return characters.count
    }

    func krm_trimming() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func krm_trimmingWhitespaces() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func krm_fullRange() -> NSRange {
        return NSMakeRange(0, self.krm_length)
    }
    
    func krm_substring(withRange range: NSRange) -> String {
        let start = self.startIndex.advancedBy(range.location)
        let end = start.advancedBy(range.length)
        
        return self.substringWithRange(start..<end)
    }
    
}


extension CLAuthorizationStatus {

    var krm_description: String {
        switch self {
        case .NotDetermined:
            return "NotDetermined"
        case .Restricted:
            return "Restricted"
        case .Denied:
            return "Denied"
        case .AuthorizedAlways:
            return "AuthorizedAlways"
        case .AuthorizedWhenInUse:
            return "AuthorizedWhenInUse"
        default:
            return "Unknown"
        }
    }

}