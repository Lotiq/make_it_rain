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
        view.backgroundColor = UIColor.themeColor.main
        navigationController?.navigationBar.barTintColor = UIColor.themeColor.secondary
        navigationController?.navigationBar.isTranslucent = false
        // Do any additional setup after loading the view.
    }
    
    @IBAction func myCurrenciesAction(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MyCurrenciesTableViewController") as! MyCurrenciesTableViewController
        vc.doublePresenting = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func aboutAction(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
