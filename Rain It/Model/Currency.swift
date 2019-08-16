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
    var images = [Int: String]() // stores the name of the image
    var availableBanknotes: Set<Int>
    static var cachedImages = NSCache<NSString, UIImage>()
    static func initiate() {
        Currency.userDefinedCurrencies = Currency.getUserDefinedCurrencies()
        Currency.cachedImages.countLimit = 30
    }
    
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
                self.images[banknote.key] = imageName
                let cacheImageName = NSString(string: name + "_" + imageName + "_" + "\(banknote.key)")
                Currency.cachedImages.setObject(banknote.value, forKey: cacheImageName)
            } catch {
                return
            }
 
        }
    }
    
    // returns images as images when needed, but stores them as Files and has a URL Path
    func getImages() -> [Int:UIImage]{
        var unarchivedImages = [Int:UIImage]()

        if !self.images.isEmpty {
            let documentDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            for imageLoc in images{
                let name = self.name + "_" + imageLoc.value + "_" + "\(imageLoc.key)"
                if let cachedImage = Currency.cachedImages.object(forKey: NSString(string: name)) {
                    unarchivedImages[imageLoc.key] = cachedImage
                    continue
                }
                
                let imageURL = documentDirectoryPath.appendingPathComponent(imageLoc.value)
                
                // HERE LIES THE CAUSE OF A LOT OF SUFFERING
                let imageData = try? Data(contentsOf: imageURL)
                let image = UIImage(data: imageData!)!
                
                unarchivedImages[imageLoc.key] = image
                
                Currency.cachedImages.setObject(image, forKey: NSString(string: name))
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
                
                if FileManager.default.fileExists(atPath: imageURL.path) {
                    try? FileManager.default.removeItem(atPath: imageURL.path)
                } else {
                    print("file doesn't exist")
                }
                
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
    
    static func isIntableFor(num: Int,in currency: Currency) -> Bool {
        let currencies = allCurrencies
        var min: Double = defaultCurrencies[0].ratio
        for currency in currencies {
            if currency.ratio < min {
                min = currency.ratio
            }
        }
        
        if (Double(Int.max) < (Double(num)*currency.ratio)/min){
            return false
        } else {
            return true
        }
    }
}

extension Currency{
    
    static var defaultCurrencies: [Currency] {
        let dollar = Currency(name: "dollar", sign: "$", ratio: 1, availableBanknotes: [1,5,10,20,100])
        let euro = Currency(name: "euro", sign: "€", ratio: 1.13, availableBanknotes: [5,10,50,100])
        let pound = Currency(name: "pound", sign: "£", ratio: 1.3, availableBanknotes: [5,10,50])
        let renminbi = Currency(name: "renminbi", sign: "¥", ratio: 0.14, availableBanknotes: [5,10,50,100])
        return [dollar,euro,pound,renminbi]
    }
    
    static var userDefinedCurrencies: [Currency] = []
    
    static var allCurrencies: [Currency] {
        return Currency.userDefinedCurrencies + Currency.defaultCurrencies
    }
    
    static func getUserDefinedCurrencies() -> [Currency] {
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
    
    static func setUserDefined(Currencies currencies: [Currency]) {
        Currency.userDefinedCurrencies = currencies
        UserDefaults.standard.set(try? PropertyListEncoder().encode(currencies), forKey: Currency.currencyArrayKey)
    }
}
