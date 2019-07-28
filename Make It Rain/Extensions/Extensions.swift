//
//  Extensions.swift
//  Make It Rain
//
//  Created by Timothy on 4/13/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: Float = 1) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(a))
    }
    
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
    
    struct theme{
        static let main = #colorLiteral(red: 0.1647058824, green: 0.3725490196, blue: 0.2666666667, alpha: 1)
        static let secondary = #colorLiteral(red: 0.7294117647, green: 0.8117647059, blue: 0.6823529412, alpha: 1)
        static let gray = #colorLiteral(red: 0.8, green: 0.7843137255, blue: 0.7294117647, alpha: 1)
        static let gold = #colorLiteral(red: 0.9137254902, green: 0.8274509804, blue: 0.4549019608, alpha: 1)
    }
}

// Returns all characters in a font
extension NSCharacterSet {
    var characters:[String] {
        var chars = [String]()
        for plane:UInt8 in 0...16 {
            if self.hasMemberInPlane(plane) {
                let p0 = UInt32(plane) << 16
                let p1 = (UInt32(plane) + 1) << 16
                for c:UTF32Char in p0..<p1 {
                    if self.longCharacterIsMember(c) {
                        var c1 = c.littleEndian
                        let s = NSString(bytes: &c1, length: 4, encoding: String.Encoding.utf32LittleEndian.rawValue)!
                        chars.append(String(s))
                    }
                }
            }
        }
        return chars
    }
}

// Tints image
extension UIImage {
    func tint(with color: UIColor) -> UIImage {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        
        image.draw(in: CGRect(origin: .zero, size: size))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

// Turns double to a string avoiding scientific notation
extension Double {
    
    func toString(decimal: Int = 9) -> String {
        let value = decimal < 0 ? 0 : decimal
        var string = String(format: "%.\(value)f", self)
        
        while string.last == "0" || string.last == "." {
            if string.last == "." { string = String(string.dropLast()); break}
            string = String(string.dropLast())
        }
        return string
    }
}
