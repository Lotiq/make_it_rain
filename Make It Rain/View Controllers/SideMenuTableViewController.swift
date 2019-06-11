//
//  SideMenuTableViewController.swift
//  Make It Rain
//
//  Created by Timothy on 4/29/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class SideMenuTableViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.theme.main
        navigationController?.navigationBar.barTintColor = UIColor.theme.secondary
        navigationController?.navigationBar.isTranslucent = false
    }
    
    @IBAction func myCurrenciesAction(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MyCurrenciesTableViewController") as! MyCurrenciesTableViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func aboutAction(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
