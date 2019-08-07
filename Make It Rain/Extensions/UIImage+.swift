//
//  UIImage+.swift
//  Make It Rain
//
//  Created by Tsimafei Lobiak on 8/7/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation
import UIKit

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
