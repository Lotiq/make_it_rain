//
//  ViewController.swift
//  Make It Rain
//
//  Created by Timothy on 4/13/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit
import HGCircularSlider

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var slider: CircularSlider!
    @IBOutlet weak var playBarButton: UIBarButtonItem!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var cashTextField: UITextField!
    
    var currencies: [String:String] = ["dollar":"$","peso":"$"]
    var selectedCurrency: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlider(slider: slider)
        view.backgroundColor = UIColor(patternImage: UIImage(named: "money.jpg")!)
        //navigationController?.navigationBar.backgroundColor = UIColor.themeColor.main
        navigationController?.navigationBar.barTintColor = UIColor.themeColor.main
        // Do any additional setup after loading the view, typically from a nib.
        playBarButton.tintColor = UIColor.themeColor.extra
        menuBarButton.tintColor = UIColor.themeColor.extra
        //menuBarButton.image
        cashTextField.delegate = self
        slider.addTarget(self, action: #selector(updateCashValue), for: .valueChanged)
        selectedCurrency = currencies["dollar"]!
        
    }
    
    
    func setupSlider(slider: CircularSlider){
        slider.minimumValue = 0
        slider.maximumValue = 10000
        slider.diskColor = .clear
        slider.trackFillColor = UIColor.themeColor.main
        slider.thumbRadius = 16
        slider.trackColor = UIColor.themeColor.gray
        slider.backtrackLineWidth = 6
        slider.lineWidth = 14
        slider.endThumbStrokeColor = UIColor.themeColor.main
        slider.endThumbTintColor = UIColor.themeColor.extra
        slider.thumbLineWidth = 8
        slider.endPointValue = 300
        slider.endThumbStrokeHighlightedColor = UIColor.themeColor.main
        slider.backgroundColor = .clear
        //slider.trackShadowColor = .red
        
        
    }
    
    @objc func updateCashValue(){
        let newValue = Int(slider.endPointValue)
        cashTextField.text = selectedCurrency + "\(newValue)"
        
    }
    
    
    
    func updateSlider(num: Int){
        slider.endPointValue = num < Int(slider.maximumValue) ? CGFloat(num) : slider.maximumValue - 1
    }
    
    // MARK: TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        let modifiedText = newText.replacingOccurrences(of: selectedCurrency, with: "")
        
        guard let num = Int(modifiedText) else {
            if (modifiedText == ""){
                textField.text = selectedCurrency
                updateSlider(num: 0)
            }
            return false
        }
        
        textField.text = selectedCurrency + "\(num)"
        updateSlider(num: num)
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text == selectedCurrency){
            textField.text = selectedCurrency + "0"
        }
        textField.resignFirstResponder()
        return true
    }
}

