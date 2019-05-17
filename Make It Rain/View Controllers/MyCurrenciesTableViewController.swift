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
    @IBOutlet weak var addNewCurrencyButton: CircularButton!
    var doublePresenting = false
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
        if (!doublePresenting){
            super.viewWillAppear(animated)
            userDefaultCurrencies = Currency.userDefaultCurrencies
            currencyTableView.reloadData()
            print("viewWillAppear")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove all animations.
        for view in view.subviews {
            view.layer.removeAllAnimations()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (!doublePresenting){
            super.viewDidAppear(animated)
            print("viewDidAppear")
            for i in 0..<userDefaultCurrencies.count{
                let cell = self.currencyTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? MyCurrencyTableViewCell
                cell?.transform = CGAffineTransform(translationX: 0, y: view.frame.maxY)
                
                UIView.animate(
                    withDuration: 1.4,
                    delay: 0.07 * Double(i),
                    animations: {
                        cell?.contentView.alpha = 1
                })
                
                UIView.animate(
                    withDuration: 0.7,
                    delay: 0.07 * Double(i),
                    animations: {
            
                        cell?.transform = .identity
                })
            }
        } else {
            doublePresenting = false
        }
        
    }
    
    @IBAction func newCurrencyAction(_ sender: Any) {
        let newCurrencyVC = storyboard?.instantiateViewController(withIdentifier: "NewCurrencyViewController") as! NewCurrencyViewController
        self.navigationController?.pushViewController(newCurrencyVC, animated: true)
    }
    
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userDefaultCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCurrencyTableViewCell", for: indexPath) as! MyCurrencyTableViewCell
        let image = userDefaultCurrencies[indexPath.row].getImages().randomElement()!.value // force unwrapping is not good, fix later
        cell.sampleBanknoteImageView.image = image
        cell.nameLabel.text = userDefaultCurrencies[indexPath.row].name
        cell.contentView.alpha = 0
        // Configure the cell...

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editCurrencyVC = storyboard?.instantiateViewController(withIdentifier: "NewCurrencyViewController") as! NewCurrencyViewController
        editCurrencyVC.isEdited = true
        editCurrencyVC.passedIndexValue = (indexPath.row,userDefaultCurrencies[indexPath.row])
        navigationController?.pushViewController(editCurrencyVC, animated: true)
    }

    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currency = userDefaultCurrencies[indexPath.row]
            currency.deleteImages()
            userDefaultCurrencies.remove(at: indexPath.row)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(userDefaultCurrencies), forKey: Currency.currencyArrayKey)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width * 0.5
    }

}
