//
//  BanknoteViewController.swift
//  Make It Rain
//
//  Created by Timothy on 4/15/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit
import CenteredCollectionView



class BanknoteViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var banknoteCollectionView: UICollectionView!
    var banknotes = ["dollar", "peso"]
    var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()

        centeredCollectionViewFlowLayout = (banknoteCollectionView.collectionViewLayout as! CenteredCollectionViewFlowLayout)
        // Modify the collectionView's decelerationRate (REQURED STEP)
        banknoteCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        // Assign delegate and data source
        banknoteCollectionView.delegate = self
        banknoteCollectionView.dataSource = self
        banknoteCollectionView.backgroundView?.backgroundColor = .clear
        banknoteCollectionView.backgroundColor = .clear
        
        // Configure the required item size (REQURED STEP)
        centeredCollectionViewFlowLayout.itemSize = CGSize(
            width: view.bounds.width * 0.7,
            height: view.bounds.height * 0.7
        )
        
        // Configure the optional inter item spacing (OPTIONAL STEP)
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
        let imageName = banknotes[indexPath.row] + ".jpg"
        cell.banknoteImageView.image = UIImage(named: imageName)
        return cell
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
