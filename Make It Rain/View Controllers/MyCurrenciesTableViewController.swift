//
//  MyCurrenciesTableViewController.swift
//  Make It Rain
//
//  Created by Timothy on 4/29/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class MyCurrenciesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - IBOutlets
    @IBOutlet weak var currencyTableView: UITableView!
    @IBOutlet weak var addNewCurrencyButton: CircularButton!
    
    
    // MARK: - Variables
    var userDefinedCurrencies: [Currency]!
    var allImages: [UIImage] = []
    
    // MARK: - Override Presenting Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyTableView.backgroundColor = UIColor.theme.secondary
        userDefinedCurrencies = Currency.userDefinedCurrencies
        self.navigationItem.backBarButtonItem = .createBackButtonWith(title: "Cancel")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide button to animate it in viewDidAppear
        addNewCurrencyButton.isHidden = true
        
        // The only place where the the table gets data for the cells
        userDefinedCurrencies = Currency.userDefinedCurrencies
        
        // Necessary images are fetched from the data
        allImages = []
        for i in 0..<userDefinedCurrencies.count {
            let image = userDefinedCurrencies[i].getImages().randomElement()!.value
            allImages.append(image)
        }
        
        // Table view updated with new data present
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
        
        // Animating 'add' button appearance
        addNewCurrencyButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        addNewCurrencyButton.isHidden = false
        
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.1, options: .curveLinear, animations: {
            self.addNewCurrencyButton.transform = .identity
        }, completion: nil)
        
    }
    
    // MARK: - IBAction
    
    @IBAction func newCurrencyAction(_ sender: Any) {
        let newCurrencyVC = storyboard?.instantiateViewController(withIdentifier: "NewCurrencyViewController") as! NewCurrencyViewController
        self.navigationController?.pushViewController(newCurrencyVC, animated: true)
    }
    
    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {return 1}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return userDefinedCurrencies.count}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCurrencyTableViewCell", for: indexPath) as! MyCurrencyTableViewCell
        cell.sampleBanknoteImageView.image = allImages[indexPath.row]
        cell.nameLabel.text = userDefinedCurrencies[indexPath.row].name

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editCurrencyVC = storyboard?.instantiateViewController(withIdentifier: "NewCurrencyViewController") as! NewCurrencyViewController
        
        // Pass an additional values to indicate that the currency is being edited, but not created new
        editCurrencyVC.isEdited = true
        editCurrencyVC.passedIndexValue = (indexPath.row,userDefinedCurrencies[indexPath.row])
        navigationController?.pushViewController(editCurrencyVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {return tableView.frame.width * 0.5}

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currency = userDefinedCurrencies[indexPath.row]
            currency.deleteImages()
            userDefinedCurrencies.remove(at: indexPath.row)
            Currency.setUserDefined(Currencies: userDefinedCurrencies)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.alpha = 0
        
        let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
        cell.layer.transform = transform
        
        UIView.animate(withDuration: 0.7) {
            cell.contentView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.6) {
            cell.layer.transform = CATransform3DIdentity
        }
    }

}
