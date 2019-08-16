//
//  Extensions.swift
//  Make It Rain
//
//  Created by Timothy on 4/13/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    static func createBackButtonWith(title: String) -> UIBarButtonItem {
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: nil)
        let navigationFont = UIFont(name: "Montserrat Medium", size: 24)
        button.tintColor = UIColor.theme.gold
        button.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.theme.gold, NSAttributedString.Key.font: navigationFont!], for: .normal)
        button.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.theme.gold, NSAttributedString.Key.font: navigationFont!], for: .highlighted)
        button.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.theme.gold, NSAttributedString.Key.font: navigationFont!], for: .disabled)
        button.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.theme.gold, NSAttributedString.Key.font: navigationFont!], for: .focused)

        return button
    }
}
