//
//  UIColor+String.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    class func hexStringToUIColor (_ hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString = cString.trimmingCharacters(in: CharacterSet.punctuationCharacters as CharacterSet)
        }
        
        if cString.count != 6 {
            return UIColor.gray
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class func rgbStringToUIColor (_ rgb: String) -> UIColor {
        var colorArray: [String]
        var cString = rgb.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("RGB") {
            cString = cString.replacingOccurrences(of: "RGB", with: "")
            cString = cString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines as CharacterSet)
        }
        
        if rgb.contains(",") {
            colorArray = rgb.split { $0 == "," }.map(String.init)
        } else if rgb.contains(".") {
            colorArray = rgb.split { $0 == "." }.map(String.init)
        } else if rgb.contains("/") {
            colorArray = rgb.split { $0 == "/" }.map(String.init)
        } else if rgb.contains("|") {
            colorArray = rgb.split { $0 == "|" }.map(String.init)
        } else {
            colorArray = rgb.split { $0 == " " }.map(String.init)
        }
        
        return UIColor(
            red: cgFloatFromString(colorArray[0]) / 255.0,
            green: cgFloatFromString(colorArray[1]) / 255.0,
            blue: cgFloatFromString(colorArray[2]) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class func cgFloatFromString(_ string: String) -> CGFloat {
        let newString = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines as CharacterSet)
        return CGFloat((newString as NSString).floatValue)
    }
}
