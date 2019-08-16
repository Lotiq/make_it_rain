//
//  ActionButton.swift
//  Make It Rain
//
//  Created by Timothy on 4/26/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? UIColor.theme.gold : UIColor.lightGray
        }
    }
    
    // For storyboard
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure(){
        
        self.setTitleColor(UIColor.gray, for: .normal)
        self.setTitleColor(UIColor.gray.withAlphaComponent(0.3), for: .highlighted)
        self.titleLabel?.font = UIFont(name: "Money Money", size: 24)
        self.backgroundColor = UIColor.theme.gold
        self.layer.cornerRadius = 10
        self.layer.shadowRadius = 4.0
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = true
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        
    }
}
