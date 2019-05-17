//
//  CircularButton.swift
//  Make It Rain
//
//  Created by Timothy on 5/15/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class CircularButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? UIColor.themeColor.extra : UIColor.lightGray
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
        self.titleLabel?.font = UIFont(name: "Money Money", size: 40)
        self.backgroundColor = UIColor.themeColor.extra
        
        self.layer.masksToBounds = true
        
        self.layer.shadowRadius = 4.0
        self.layer.shadowColor = UIColor.gray.cgColor //UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 1.0
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height/2
        
    }
    

}
