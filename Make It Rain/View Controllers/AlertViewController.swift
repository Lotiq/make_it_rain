//
//  AlertViewController.swift
//  Make It Rain
//
//  Created by Timothy on 5/16/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var buttonLabel: ActionButton!
    @IBOutlet weak var alertView: UIView!
    var bodyText = String()
    var titleText = String()
    var buttonText = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertView.layer.cornerRadius = 10
        alertView.layer.masksToBounds = true
        setupLabels()
    }
    
    func setupLabels(){
        titleLabel.text = titleText
        bodyLabel.text = bodyText
        buttonLabel.setTitle(buttonText, for: .normal)
    }
    
    @IBAction func actionButtonPressed(_ sender: ActionButton) {
        dismiss(animated: true, completion: nil)
    }
}
