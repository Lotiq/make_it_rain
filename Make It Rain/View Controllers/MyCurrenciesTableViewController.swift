//
//  MyCurrenciesTableViewController.swift
//  Make It Rain
//
//  Created by Timothy on 4/29/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class MyCurrenciesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var currencyTableView: UITableView!
    var userDefaultCurrencies: [Currency]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyTableView.backgroundColor = UIColor.themeColor.secondary
        currencyTableView.separatorStyle = .none
        userDefaultCurrencies = Currency.userDefaultCurrencies

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: nil)
        cancelButton.tintColor = UIColor.themeColor.extra
        let navigationFont = UIFont(name: "Montserrat Medium", size: 24)
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.themeColor.extra, NSAttributedString.Key.font: navigationFont!], for: .normal)
        self.navigationItem.backBarButtonItem = cancelButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userDefaultCurrencies = Currency.userDefaultCurrencies
        currencyTableView.reloadData()
        print("viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
    }
    
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userDefaultCurrencies.count
    }

    @IBAction func newCurrencyAction(_ sender: Any) {
        let newCurrencyVC = storyboard?.instantiateViewController(withIdentifier: "NewCurrencyViewController") as! NewCurrencyViewController
        self.navigationController?.pushViewController(newCurrencyVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCurrencyTableViewCell", for: indexPath) as! MyCurrencyTableViewCell
        let image = userDefaultCurrencies[indexPath.row].getImages().randomElement()!.value // force unwrapping is not good, fix later
        cell.sampleBanknoteImageView.image = image
        cell.nameLabel.text = userDefaultCurrencies[indexPath.row].name
        
        // Configure the cell...

        return cell
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editCurrencyVC = storyboard?.instantiateViewController(withIdentifier: "NewCurrencyViewController") as! NewCurrencyViewController
        editCurrencyVC.isEdited = true
        editCurrencyVC.passedIndexValue = (indexPath.row,userDefaultCurrencies[indexPath.row])
        navigationController?.pushViewController(editCurrencyVC, animated: true)
    }

    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            userDefaultCurrencies.remove(at: indexPath.row)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(userDefaultCurrencies), forKey: Currency.currencyArrayKey)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width * 0.5
    }

}
