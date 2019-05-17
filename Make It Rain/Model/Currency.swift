//
//  CurrencyModel.swift
//  Make It Rain
//
//  Created by Timothy on 4/16/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation
import UIKit

struct Currency: Codable, Equatable {
    
    static let currencyArrayKey = "currencyArrayKey"
    static var selectedCurrency: Currency = Currency.allCurrencies[0]
    static var dollarValue: Int = 1000
    
    let name: String
    let sign: String
    var ratio: Double // 1:ratio to dollars
    fileprivate var images = [Int: String]() // stores the name of the image
    var availableBanknotes: Set<Int>
    
    fileprivate init(name: String, sign: String, ratio: Double, availableBanknotes: [Int]){
        self.name = name
        self.sign = sign
        self.ratio = ratio
        self.availableBanknotes = Set(availableBanknotes)
    }
    
    public init(name: String, sign: String, rate: Double, valueImageDictionary: [Int: UIImage] ){
        self.name = name
        self.sign = sign
        self.ratio = rate
        self.availableBanknotes = Set(valueImageDictionary.keys)
        
        for banknote in valueImageDictionary {
            
            guard let documentDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let imageName = name+"_"+String(banknote.key)+".png"
            let imgPath = documentDirectoryPath.appendingPathComponent(imageName)
            
            do {
                try banknote.value.pngData()?.write(to: imgPath, options: .atomic)
                //try banknote.value.jpegData(compressionQuality: 1)?.write(to: imgPath, options: .atomic)
                self.images[banknote.key] = imageName
                
            } catch {
                print(error.localizedDescription)
            }
 
        }
    }
    
    // returns images as images when needed, but stores them as Files and has a URL Path
    func getImages() -> [Int:UIImage]{
        var unarchivedImages = [Int:UIImage]()

        if !self.images.isEmpty {
            let documentDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            for imageLoc in images{
                let imageURL = documentDirectoryPath.appendingPathComponent(imageLoc.value)
                //let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("Image2.png")
                let image = UIImage(contentsOfFile: imageURL.path)
                unarchivedImages[imageLoc.key] = image
            }
        } else {
            for banknote in self.availableBanknotes {
                let imageName = self.name + "_" + String(banknote)
                let imageNameFull = imageName + ".jpg"
                let image = UIImage(named: imageNameFull)!
                unarchivedImages[banknote] = image
            }
        }
        
        return unarchivedImages
    }
    
    func deleteImages(){
        if !self.images.isEmpty {
            let documentDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            for imageLoc in images{
                let imageURL = documentDirectoryPath.appendingPathComponent(imageLoc.value)
                try? FileManager.default.removeItem(at: imageURL)
            }
        }
    }
    
    static func distributeCurrencyDescending() -> [Int : Int]{
        let availableBanknotes = Currency.selectedCurrency.availableBanknotes
        let money = Int(Double(Currency.dollarValue)/Currency.selectedCurrency.ratio)
        var output = [Int : Int]()
        var r = money
        var mutableAvailableBanknotes = availableBanknotes
        while(r >= availableBanknotes.min()!){
            let newMax = mutableAvailableBanknotes.max()!
            let (quotient, remainder) = r.quotientAndRemainder(dividingBy: newMax)
            r = remainder
            output[newMax] = quotient
            mutableAvailableBanknotes.remove(newMax)
        }
        
        // Rounding up so at least 1 currency
        if r > 0 {
            if let val = output[availableBanknotes.min()!]{
                output[availableBanknotes.min()!] = val + 1
            } else {
                output[availableBanknotes.min()!] = 1
            }
        }
        
        return output
    }
    
    static func isRenderableFor(maxcount: Int) -> Bool {
        let output = distributeCurrencyDescending()
        let count = output.reduce(0) { (total, entry) -> Int in
            total + entry.value
        }
        
        return count <= maxcount
    }
}

extension Currency{
    
    static var localCurrencies: [Currency] {
        let dollar = Currency(name: "dollar", sign: "$", ratio: 1, availableBanknotes: [1,5,20,100])
        let euro = Currency(name: "euro", sign: "€", ratio: 1.13, availableBanknotes: [5])
        let pound = Currency(name: "pound", sign: "£", ratio: 1.3, availableBanknotes: [5,50])
        let yuan = Currency(name: "yuan", sign: "¥", ratio: 0.15, availableBanknotes: [50])
        return [dollar,euro,pound,yuan]
    }
    
    static var userDefaultCurrencies: [Currency] {
        if let data = UserDefaults.standard.value(forKey: currencyArrayKey) as? Data {
            do{
                let currencyArray = try PropertyListDecoder().decode(Array<Currency>.self, from: data)
                return currencyArray
            } catch {
                print("My Error: Can't decode from UserDefaults")
                return []
            }
        } else {
            print("No data in User Defaults")
            return []
        }
    }
    
    static var allCurrencies: [Currency] {
        let addCurrencies = self.userDefaultCurrencies.reversed() + self.localCurrencies
        return addCurrencies
    }
}
