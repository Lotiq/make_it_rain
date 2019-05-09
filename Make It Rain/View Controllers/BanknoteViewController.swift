//
//  BanknoteViewController.swift
//  Make It Rain
//
//  Created by Timothy on 4/15/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit
import CenteredCollectionView

protocol BanknoteViewControllerDelegate{
    func updateView(ratio: Double)
    func updateBackButton()
}

class BanknoteViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var banknoteCollectionView: UICollectionView!
    @IBOutlet weak var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
    
    var banknoteViewControllerDelegate: BanknoteViewControllerDelegate?
    var banknotes = Currency.allCurrencies
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Modify the collectionView's decelerationRate
        banknoteCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        banknoteCollectionView.backgroundColor = .clear
        
        // Assign delegate and data source
        banknoteCollectionView.delegate = self
        banknoteCollectionView.dataSource = self
        
        // Configure the required item size
        centeredCollectionViewFlowLayout.itemSize = CGSize(
            width: banknoteCollectionView.bounds.width * 0.7,
            height: banknoteCollectionView.bounds.height * 0.7
        )
        
        
        // Configure the optional inter item spacing
        centeredCollectionViewFlowLayout.minimumLineSpacing = 20
        //banknoteCollectionView.collectionViewLayout = centeredCollectionViewFlowLayout
        // Get rid of scrolling indicators
        banknoteCollectionView.showsVerticalScrollIndicator = false
        banknoteCollectionView.showsHorizontalScrollIndicator = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        banknotes = Currency.allCurrencies
        banknoteCollectionView.reloadData()
        let index = banknotes.firstIndex(of: Currency.selectedCurrency) ?? 0
        let ratio = Currency.selectedCurrency.ratio/banknotes[index].ratio
        Currency.selectedCurrency = banknotes[index]
        self.banknoteViewControllerDelegate?.updateView(ratio: ratio)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let index = banknotes.firstIndex(of: Currency.selectedCurrency) ?? 0
        
        centeredCollectionViewFlowLayout.scrollToPage(index: index+1, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banknotes.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "banknoteCell", for: indexPath) as! BanknoteCell
        
        // Check if the cell is not the one reserved for new currencies
        if (indexPath.row != 0){
            let images = banknotes[indexPath.row-1].getImages()
        
            let image = images[5] ?? images.randomElement()!.value
            cell.banknoteImageView.image = image
        } else {
            let image = UIImage(named: "newCurrency.jpg")
            cell.banknoteImageView.image = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // check if the currentCenteredPage is not the page that was touched
        let currentCenteredPage = centeredCollectionViewFlowLayout.currentCenteredPage
        
        if currentCenteredPage != indexPath.row {
            centeredCollectionViewFlowLayout.scrollToPage(index: indexPath.row, animated: true)
            if (indexPath.row != 0){
                let ratio = Currency.selectedCurrency.ratio/banknotes[indexPath.row-1].ratio
                Currency.selectedCurrency = banknotes[indexPath.row-1]
                self.banknoteViewControllerDelegate?.updateView(ratio: ratio)
            }
        } else {
            // tapped again
            if (indexPath.row == 0){
                let nextVC = storyboard?.instantiateViewController(withIdentifier: "NewCurrencyViewController") as! NewCurrencyViewController
                self.banknoteViewControllerDelegate?.updateBackButton()
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    // MARK: Scroll View to Track current location
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (centeredCollectionViewFlowLayout.currentCenteredPage != 0){
            let ratio = Currency.selectedCurrency.ratio/banknotes[centeredCollectionViewFlowLayout.currentCenteredPage!-1].ratio
            Currency.selectedCurrency = banknotes[centeredCollectionViewFlowLayout.currentCenteredPage!-1]
            self.banknoteViewControllerDelegate?.updateView(ratio: ratio)
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
