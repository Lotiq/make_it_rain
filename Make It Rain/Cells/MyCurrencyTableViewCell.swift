//
//  MyCurrencyTableViewCell.swift
//  Make It Rain
//
//  Created by Timothy on 4/29/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class MyCurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sampleBanknoteImageView: UIImageView!
    @IBOutlet weak var containerBanknoteView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerBanknoteView.layer.cornerRadius = 10
        self.backgroundColor = .clear
        self.sampleBanknoteImageView.layer.cornerRadius = 10
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        let overlay: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.sampleBanknoteImageView.frame.size.width, height: self.sampleBanknoteImageView.frame.size.height))
        overlay.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
        overlay.layer.cornerRadius = self.containerBanknoteView.layer.cornerRadius
        self.sampleBanknoteImageView.addSubview(overlay)
    }
}
