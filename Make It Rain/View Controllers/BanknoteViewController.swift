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
}

class BanknoteViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var banknoteCollectionView: UICollectionView!
    
    var banknoteViewControllerDelegate: BanknoteViewControllerDelegate?
    var banknotes = Currency.allCurrencies
    var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        centeredCollectionViewFlowLayout = (banknoteCollectionView.collectionViewLayout as! CenteredCollectionViewFlowLayout)
        
        // Modify the collectionView's decelerationRate
        banknoteCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        banknoteCollectionView.backgroundColor = .clear
        
        // Assign delegate and data source
        banknoteCollectionView.delegate = self
        banknoteCollectionView.dataSource = self
        
        // Configure the required item size
        centeredCollectionViewFlowLayout.itemSize = CGSize(
            width: view.bounds.width * 0.7,
            height: view.bounds.height * 0.7
        )
        
        // Configure the optional inter item spacing
        centeredCollectionViewFlowLayout.minimumLineSpacing = 20
        
        // Get rid of scrolling indicators
        banknoteCollectionView.showsVerticalScrollIndicator = false
        banknoteCollectionView.showsHorizontalScrollIndicator = false
        
    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        centeredCollectionViewFlowLayout.scrollToPage(index: 1, animated: false)
    }*/
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        centeredCollectionViewFlowLayout.scrollToPage(index: 1, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        centeredCollectionViewFlowLayout.scrollToPage(index: 1, animated: false)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banknotes.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "banknoteCell", for: indexPath) as! BanknoteCell
        
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
