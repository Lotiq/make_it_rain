//
//  ImageValueTableViewCell.swift
//  Make It Rain
//
//  Created by Timothy on 4/24/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class ImageValueTableViewCell: UITableViewCell {

    @IBOutlet weak var banknoteImage: UIImageView!
    @IBOutlet weak var valueTextField: UITextField!
    
    var tagTapGestureRecognizer: TagTapGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.valueTextField.attributedPlaceholder = NSAttributedString(string: "Value",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        // Initialization code
    }
    
}
