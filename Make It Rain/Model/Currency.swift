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
    var images = [Int: Data]()
    var availableBanknotes: Set<Int>
    
    fileprivate init(name: String, sign: String, ratio: Double, availableBanknotes: [Int]){
        self.name = name
        self.sign = sign
        self.ratio = ratio
        self.availableBanknotes = Set(availableBanknotes)
        
        for banknote in availableBanknotes {
            let imageName = name + "_" + String(banknote)
            let imageNameFull = imageName + ".jpg" // will need to accomodate other formats?
            let image = UIImage(named: imageNameFull)! // For now no checking but should be careful!!!
            self.images[banknote] = image.jpegData(compressionQuality: 1)
        }
    }
    
    public init(name: String, sign: String, rate: Double, valueImageDictionary: [Int: UIImage] ){
        self.name = name
        self.sign = sign
        self.ratio = rate
        self.availableBanknotes = Set(valueImageDictionary.keys)
        
        for banknote in valueImageDictionary {
            self.images[banknote.key] = banknote.value.jpegData(compressionQuality: 1)
        }
    }
    
    // returns images as images when needed, but stores them as Data
    func getImages() -> [Int:UIImage]{
        var unarchivedImages = [Int:UIImage]()
        for keyValue in self.images.enumerated() {
            
            let newImage = UIImage(data: keyValue.element.value)! // For now no checking but should be careful!!!
            unarchivedImages[keyValue.element.key] = newImage
        }
        return unarchivedImages
    }
}

extension Currency{
    
    static var localCurrencies: [Currency] {
        let dollar = Currency(name: "dollar", sign: "$", ratio: 1, availableBanknotes: [1,5])
        let euro = Currency(name: "euro", sign: "€", ratio: 1.13, availableBanknotes: [5])
        let pound = Currency(name: "pound", sign: "£", ratio: 1.3, availableBanknotes: [5])
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


