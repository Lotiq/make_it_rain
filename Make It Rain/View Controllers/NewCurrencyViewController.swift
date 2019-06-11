//
//  NewCurrencyViewController.swift
//  Make It Rain
//
//  Created by Timothy on 4/19/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class NewCurrencyViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var currencySignTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var rateTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var banknoteTableView: UITableView!
    
    var isEdited: Bool = false
    var passedIndexValue: (Int,Currency)!
    var latestRow: Int!
    var numOfBanknotes: Int = 1
    var topBar:CGFloat = 0
    var imageValueArray: [(UIImage,Int?)] = [(UIImage(named: "banknote.png")!,nil)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        self.setupHideKeyboardOnTap()
        saveButton.isEnabled = false
        
        view.backgroundColor = UIColor.theme.secondary
        
        navigationController?.navigationBar.barTintColor = UIColor.theme.main
        navigationController?.navigationBar.isTranslucent = false
        
        topBar = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        banknoteTableView.delegate = self
        banknoteTableView.dataSource = self
        
        setup(textField: nameTextField)
        setup(textField: currencySignTextField)
        setup(textField: rateTextField)
        
        banknoteTableView.separatorColor = UIColor.white
        banknoteTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        banknoteTableView.layer.cornerRadius = 25
        banknoteTableView.backgroundColor = UIColor.theme.main
        
        if (isEdited){
            saveButton.isEnabled = true
            saveButton.setTitle("Update", for: .normal)
            
            let currency = passedIndexValue.1
            nameTextField.text = currency.name
            currencySignTextField.text = currency.sign
            rateTextField.text = String(currency.ratio)
            imageValueArray = []
            for valuePair in currency.getImages() {
                imageValueArray.append((valuePair.value,valuePair.key))
            }
            imageValueArray.append((UIImage(named: "banknote.png")!,nil))
            
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeybordNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setup(textField: SkyFloatingLabelTextField) {
        textField.delegate = self
        
        // placeholder color
        textField.placeholderColor = .darkGray

        // error colors
        textField.errorColor = .red
        textField.lineErrorColor = .red
        textField.titleErrorColor = .red
        
        // selected colors
        textField.selectedLineColor = UIColor.theme.gold
        textField.selectedTitleColor = UIColor.theme.gold
        
        // normal state colors
        textField.textColor = .white
        textField.lineColor = .white
        textField.titleColor = UIColor.theme.gold
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let name = nameTextField.text, let sign = currencySignTextField.text, let rate = Double(rateTextField.text!) else{
        
            return
        }
        
        var valueImageDictionary: [Int:UIImage] = [:]
        for i in 0..<imageValueArray.count - 1 {
            guard let value = imageValueArray[i].1 else{
                return
            }
            valueImageDictionary[value] = imageValueArray[i].0
        }
        
        guard !valueImageDictionary.isEmpty else {
            
            return
        }
        
        let newCurrency = Currency(name: name, sign: sign, rate: rate, valueImageDictionary: valueImageDictionary)
        var updatedCurrencies = Currency.userDefinedCurrencies
        if (!isEdited){
            updatedCurrencies.append(newCurrency)
        } else {
            let currency = updatedCurrencies[passedIndexValue.0]
            currency.deleteImages()
            updatedCurrencies.remove(at: passedIndexValue.0)
            updatedCurrencies.append(newCurrency)
        }
        
        do {
            UserDefaults.standard.set(try PropertyListEncoder().encode(updatedCurrencies), forKey: Currency.currencyArrayKey)
        } catch {
            print("couldn't encode array")
        }
        
        Currency.selectedCurrency = newCurrency
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkForCompletion() -> Bool{
        
        guard nameTextField.text != "", currencySignTextField.text != "", Double(rateTextField.text!) != nil, rateTextField.text != "", !currencySignTextField.hasErrorMessage , !rateTextField.hasErrorMessage else {
            return false
        }
    
        var valueImageDictionary: [Int:UIImage] = [:]
        for i in 0..<imageValueArray.count - 1 {
            
            // Check for value of each row that has an image
            guard let value = imageValueArray[i].1, value != 0 else{
                return false
            }
            
            valueImageDictionary[value] = imageValueArray[i].0
        }
        
        guard !valueImageDictionary.isEmpty else {
    
            return false
        }
        
        return true
    }
}

extension NewCurrencyViewController: UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageValueArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageValueTableViewCell") as! ImageValueTableViewCell
        
        //let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageSelectionPressed))
        cell.tagTapGestureRecognizer = TagTapGestureRecognizer(target: self, action: #selector(self.imageSelectionPressed(sender:)))
      
        cell.tagTapGestureRecognizer.row = indexPath.row
        cell.banknoteImage.addGestureRecognizer(cell.tagTapGestureRecognizer)
        cell.banknoteImage.image = imageValueArray[indexPath.row].0
        if let value = imageValueArray[indexPath.row].1{
            cell.valueTextField.text = String(value)
        } else {
            cell.valueTextField.text = ""
        }
        //cell.valueTextField.text = String(imageValueArray[indexPath.row].1)
        cell.valueTextField.textColor = .darkGray
        cell.valueTextField.delegate = self
        
        return cell
    }
    
    @objc func imageSelectionPressed(sender: TagTapGestureRecognizer){
        latestRow = sender.row
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary //Depending on the button assigns where to get images from
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Image Delegate Operation
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // checks if the image was selected
        if let image = info[.originalImage] as? UIImage {
            
            // checks if the last image was a new row or and old one to replace an existing image
            if (imageValueArray[latestRow].0 == UIImage(named: "banknote.png")){
                let tuple: (UIImage, Int?) = (UIImage(named: "banknote.png")!, nil)
                imageValueArray.append(tuple)
            }
        
            imageValueArray[latestRow].0 = image
            banknoteTableView.reloadData()
            saveButton.isEnabled = checkForCompletion()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (imageValueArray[indexPath.row].0 != UIImage(named: "banknote.png")){
                imageValueArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                // It is required to update the row index for each tap gesture as they don't get reinitiated, but just moved
                for i in 0..<tableView.numberOfRows(inSection: 0){
                    let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! ImageValueTableViewCell
                    cell.tagTapGestureRecognizer.row = i
                }
                saveButton.isEnabled = checkForCompletion()
            }
        }
    }
    
}

extension NewCurrencyViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if let skyTextField = textField as? SkyFloatingLabelTextField {
            if skyTextField == currencySignTextField {
                // Font used for the main text
                let mainFontDescriptor = UIFont(name: "Money Money", size: 20)!.fontDescriptor
                let mainCharacterSet : NSCharacterSet = mainFontDescriptor.object(forKey: UIFontDescriptor.AttributeName.characterSet) as! NSCharacterSet
                
                
                if (text.count > 3){
                    skyTextField.errorMessage = "Too Many Symbols"
                    return true
                } else {
                    // this variable checks if all the characters are contained within the required main font
                    var allExisiting = true
                    for character in text {
                        if !mainCharacterSet.characters.contains(String(character)){
                            allExisiting = false
                        }
                    }
                    
                    if allExisiting {
                        skyTextField.errorMessage = ""
                    } else {
                        skyTextField.errorMessage = "Invalid Symbols"
                    }
                    skyTextField.text = text
                    saveButton.isEnabled = checkForCompletion()
                    return false
                }
            
            } else if skyTextField == rateTextField {
                if (Double(text) != nil || text == ""){
                    if (Double(text) == 0){
                        skyTextField.errorMessage = "Rate can't be 0"
                    } else {
                        skyTextField.errorMessage = ""
                    }
                    skyTextField.text = text
                    saveButton.isEnabled = checkForCompletion()
                    return false
                } else {
                    skyTextField.errorMessage = ""
                    saveButton.isEnabled = checkForCompletion()
                    return false
                    
                }
            }
        } else {
            if let value = Int(text) {
                for i in 0..<banknoteTableView.numberOfRows(inSection: 0){
                    let cell = banknoteTableView.cellForRow(at: IndexPath(row: i, section: 0)) as! ImageValueTableViewCell
                    if (cell.valueTextField == textField){
                        imageValueArray[i].1 = value
                    }
                }
                saveButton.isEnabled = checkForCompletion()
                return true
            } else if text == ""{
                for i in 0..<banknoteTableView.numberOfRows(inSection: 0){
                    let cell = banknoteTableView.cellForRow(at: IndexPath(row: i, section: 0)) as! ImageValueTableViewCell
                    if (cell.valueTextField == textField){
                        imageValueArray[i].1 = nil
                    }
                }
                saveButton.isEnabled = checkForCompletion()
                return true
            } else {
                return false
            }
        }
        saveButton.isEnabled = checkForCompletion()
        return true
    }
    
    func subscribeToKeybordNotifications(){
        
        //Initiation of notification observation
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        
        //changes y-coordinate of the view above the keyboard if bottom text is selected
        if (!currencySignTextField.isFirstResponder && !nameTextField.isFirstResponder && !rateTextField.isFirstResponder){
            
            let tableViewYLoc = banknoteTableView.frame.minY
            view.frame.origin.y -= tableViewYLoc - 5
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        view.frame.origin.y = topBar
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        //Gets keyboard height
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        //Removes this control view as observer for notifications
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    
    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}
