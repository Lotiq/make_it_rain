//
//  Double+.swift
//  Make It Rain
//
//  Created by Tsimafei Lobiak on 8/7/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation

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
