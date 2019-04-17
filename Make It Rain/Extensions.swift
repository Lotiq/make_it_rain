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
        static let secondary = #colorLiteral(red: 0.5862457752, green: 0.7702537179, blue: 0.4708444476, alpha: 1)
        static let gray = #colorLiteral(red: 0.8014289141, green: 0.7830495238, blue: 0.7300147414, alpha: 1)
        static let extra = #colorLiteral(red: 0.9134007692, green: 0.8268355727, blue: 0.4537941813, alpha: 1)
        static let gold = #colorLiteral(red: 0.8106517196, green: 0.6584199667, blue: 0.1929169595, alpha: 1)
    }
}

/*
extension UserDefaults {
    
    func imageForKey(key: String) -> UIImage? {
        var image: UIImage?
        if let imageData = data(forKey: key) {
            do {
                image = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [UIImage.self], from: imageData) as? UIImage
            } catch {
                print("My Error: Couldn't unarchive")
            }
        }
        return image
    }
    
    func setImage(image: UIImage?, forKey key: String) {
        var imageData: Data?
        if let image = image {
            //imageData = NSKeyedArchiver.archivedData(withRootObject: image) as NSData?
            do {
                imageData = try NSKeyedArchiver.archivedData(withRootObject: image, requiringSecureCoding: false)
            } catch {
                print("My Error: Couldn't archive")
            }
        }
        set(imageData, forKey: key)
    }
}*/
