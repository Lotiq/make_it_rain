//
//  UIColor+.swift
//  Make It Rain
//
//  Created by Tsimafei Lobiak on 8/7/19.
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
