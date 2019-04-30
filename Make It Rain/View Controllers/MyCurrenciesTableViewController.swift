//
//  MyCurrenciesTableViewController.swift
//  Make It Rain
//
//  Created by Timothy on 4/29/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class MyCurrenciesTableViewController: UITableViewController {

    var userDefaultCurrencies: [Currency]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userDefaultCurrencies.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editCurrencyVC = storyboard?.instantiateViewController(withIdentifier: "NewCurrencyViewController") as! NewCurrencyViewController
        editCurrencyVC.isEdited = true
        editCurrencyVC.passedIndexValue = (indexPath.row,userDefaultCurrencies[indexPath.row])
        navigationController?.pushViewController(editCurrencyVC, animated: true)
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            userDefaultCurrencies.remove(at: indexPath.row)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(userDefaultCurrencies), forKey: Currency.currencyArrayKey)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
