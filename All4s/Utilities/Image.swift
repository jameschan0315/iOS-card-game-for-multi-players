//
//  Image.swift
//  War
//
//  Created by Adrian Bartholomew2 on 1/28/16.
//  Copyright © 2016 GB Software. All rights reserved.
//

import UIKit

extension UIImage {
    enum ImageSection {
        case All
        case Upper
        case Middle
        case Lower
    }
    
    func areaAverage(_ section: ImageSection = .Middle) -> UIColor {
		var bitmap = [UInt8](repeating: 0, count: 4)
		
		// Get average color.
		let context = CIContext()
		let inputImage = ciImage ?? CoreImage.CIImage(cgImage: cgImage!)
		let extent = inputImage.extent
        var y: CGFloat
        var h: CGFloat
        switch section {
        case .Upper:
            y = extent.origin.y + extent.size.height / 2
            h = extent.size.height / 2
        case .Middle:
            y = extent.origin.y + extent.size.height / 4
            h = extent.size.height / 2
        case .Lower:
            y = extent.origin.y
            h = extent.size.height / 2
        case .All:
            y = extent.origin.y
            h = extent.size.height
        }
		let inputExtent = CIVector(x: extent.origin.x, y: y, z: extent.size.width, w: h)
		let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
		let outputImage = filter.outputImage!
		let outputExtent = outputImage.extent
		assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
		
		// Render to bitmap.
		context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
		
		// Compute result.
		let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
		return result
	}
	
	func imageResize (_ sizeChange:CGSize)-> UIImage{
		
		let hasAlpha = true
		let scale: CGFloat = 0.0 // Use scale factor of main screen
		
		UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
		self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
		
		return UIGraphicsGetImageFromCurrentImageContext()! // scaled image
	}
	
	
	func tintWithColor(_ color:UIColor)->UIImage {
		
		UIGraphicsBeginImageContext(self.size)
		let context = UIGraphicsGetCurrentContext()
  
		// flip the image
		context?.scaleBy(x: 1.0, y: -1.0)
		context?.translateBy(x: 0.0, y: -self.size.height)
		
		// multiply blend mode
		context?.setBlendMode(CGBlendMode.multiply)
		
		let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
		context?.clip(to: rect, mask: self.cgImage!)
		color.setFill()
		context?.fill(rect)
		
		// create uiimage
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
}
