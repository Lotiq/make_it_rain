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
    func updateView()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banknotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "banknoteCell", for: indexPath) as! BanknoteCell
        let images = banknotes[indexPath.row].getImages()
        let image = images[5] ?? images.randomElement()!.value
        cell.banknoteImageView.image = image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // check if the currentCenteredPage is not the page that was touched
        let currentCenteredPage = centeredCollectionViewFlowLayout.currentCenteredPage
        if currentCenteredPage != indexPath.row {
            // trigger a scrollToPage(index: animated:)
            centeredCollectionViewFlowLayout.scrollToPage(index: indexPath.row, animated: true)
        }
    }
    
    // MARK: Scroll View to Track current location
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        Currency.selectedCurrency = banknotes[centeredCollectionViewFlowLayout.currentCenteredPage!]
        self.banknoteViewControllerDelegate?.updateView()
    }
}
