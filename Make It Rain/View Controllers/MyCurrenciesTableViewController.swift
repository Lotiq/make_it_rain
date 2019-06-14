//
//  MyCurrenciesTableViewController.swift
//  Make It Rain
//
//  Created by Timothy on 4/29/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class MyCurrenciesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: IBOutlets
    
    @IBOutlet weak var currencyTableView: UITableView!
    @IBOutlet weak var addNewCurrencyButton: CircularButton!
    
    
    // MARK: Variables
    // Local user default
    var userDefinedCurrencies: [Currency]!
    
    // MARK: Override Presenting Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyTableView.backgroundColor = UIColor.theme.secondary
        userDefinedCurrencies = Currency.userDefinedCurrencies
        setupBackButtonWith(title: "Cancel")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userDefinedCurrencies = Currency.userDefinedCurrencies
        currencyTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove all animations.
        for view in view.subviews {
            view.layer.removeAllAnimations()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Animations
        for i in 0..<userDefinedCurrencies.count{
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
    }
    
    
    // MARK: IBAction
    
    @IBAction func newCurrencyAction(_ sender: Any) {
        let newCurrencyVC = storyboard?.instantiateViewController(withIdentifier: "NewCurrencyViewController") as! NewCurrencyViewController
        self.navigationController?.pushViewController(newCurrencyVC, animated: true)
    }
    
    
    // MARK: Supporting functions
    
    func setupBackButtonWith(title: String) {
        let cancelButton = UIBarButtonItem(title: title, style: .plain, target: self, action: nil)
        let navigationFont = UIFont(name: "Montserrat Medium", size: 24)
        cancelButton.tintColor = UIColor.theme.gold
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.theme.gold, NSAttributedString.Key.font: navigationFont!], for: .normal)
        self.navigationItem.backBarButtonItem = cancelButton
    }
    
    
    // MARK: Table View

    func numberOfSections(in tableView: UITableView) -> Int {return 1}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return userDefinedCurrencies.count}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCurrencyTableViewCell", for: indexPath) as! MyCurrencyTableViewCell
        let image = userDefinedCurrencies[indexPath.row].getImages().randomElement()!.value
        cell.sampleBanknoteImageView.image = image
        cell.nameLabel.text = userDefinedCurrencies[indexPath.row].name
        cell.contentView.alpha = 0

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editCurrencyVC = storyboard?.instantiateViewController(withIdentifier: "NewCurrencyViewController") as! NewCurrencyViewController
        // Pass additional values to indicate that the currency is being edited, but not created new
        editCurrencyVC.isEdited = true
        editCurrencyVC.passedIndexValue = (indexPath.row,userDefinedCurrencies[indexPath.row])
        navigationController?.pushViewController(editCurrencyVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return tableView.frame.width * 0.5}

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // ADD A PUBLIC MODEL FUNCTION FOR DELETING
            let currency = userDefinedCurrencies[indexPath.row]
            currency.deleteImages()
            userDefinedCurrencies.remove(at: indexPath.row)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(userDefinedCurrencies), forKey: Currency.currencyArrayKey)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
