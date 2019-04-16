//
//  CashTextField.swift
//  Make It Rain
//
//  Created by Timothy on 4/15/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class CashTextField: UITextField {
    
    // Change the size of the cursor to accomodate font
    override func caretRect(for position: UITextPosition) -> CGRect {
        var superRect = super.caretRect(for: position)
        guard let font = self.font else { return superRect }
        
        superRect.size.height = font.pointSize + 0.29*font.descender
        return superRect
    }
    
    
    // Override bounds function to avoid first character getting overlapped on editing
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: UIEdgeInsets.init(top: 1, left: 8, bottom: 1, right: 5))
    }
 
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: UIEdgeInsets.init(top: 1, left: 0, bottom: 1, right: 5))
    }

}
