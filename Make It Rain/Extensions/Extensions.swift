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
    
    struct themeColor{
        static let main = #colorLiteral(red: 0.1631833613, green: 0.3730655909, blue: 0.2650748491, alpha: 1)
        static let secondary = #colorLiteral(red: 0.731172502, green: 0.8121758103, blue: 0.6814717054, alpha: 1)
        static let gray = #colorLiteral(red: 0.8, green: 0.7843137255, blue: 0.7294117647, alpha: 1)
        static let extra = #colorLiteral(red: 0.9137254902, green: 0.8274509804, blue: 0.4549019608, alpha: 1)
        static let gold = #colorLiteral(red: 0.8106517196, green: 0.6584199667, blue: 0.1929169595, alpha: 1)
    }
}

extension CGPoint {
    static func random(_ xsize: CGFloat, _ ysize: CGFloat)->CGPoint { return CGPoint(x:CGFloat((arc4random()%UInt32(xsize))),y:CGFloat((arc4random()%UInt32(ysize))))}
}

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
