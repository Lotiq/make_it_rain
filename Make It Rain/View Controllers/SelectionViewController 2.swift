//
//  ViewController.swift
//  Make It Rain
//
//  Created by Timothy on 4/13/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit
import SideMenu
import HGCircularSlider

class SelectionViewController: UIViewController, BanknoteViewControllerDelegate {

    @IBOutlet weak var slider: CircularSlider!
    @IBOutlet weak var playBarButton: PulsingBarButtonItem!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var cashTextField: CashTextField!

    var banknoteVC: BanknoteViewController!
    var topBar: CGFloat = 0
    var pulseLayers: [CAShapeLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let FirstViewController = storyboard!.instantiateViewController(withIdentifier: "SideMenuTableViewController") as? SideMenuTableViewController 
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: FirstViewController!)
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuPresentMode = .viewSlideInOut
        SideMenuManager.default.menuShadowColor = UIColor.darkGray
        SideMenuManager.default.menuAnimationBackgroundColor = UIColor.theme.secondary
        
        setupSlider(slider: slider)

        view.backgroundColor = UIColor.theme.secondary
        topBar = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        navigationController?.navigationBar.barTintColor = UIColor.theme.main
        navigationController?.navigationBar.isTranslucent = false
        
        
        let button = UIButton(type: .custom)
        let image = UIImage(named: "plays")!.withRenderingMode(.alwaysTemplate)
        button.setImage(image.tint(with: UIColor.theme.gold), for: .normal)
        button.tintColor = UIColor.theme.gold
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(presentARVC), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 44)
        playBarButton.customView = button
        
        menuBarButton.tintColor = UIColor.theme.gold
        menuBarButton.image = UIImage(named: "list.png")
        
        cashTextField.layer.masksToBounds = false
        cashTextField.layer.shadowRadius = 3.0
        cashTextField.layer.shadowColor = UIColor.darkGray.cgColor
        cashTextField.layer.shadowOffset = CGSize(width: 1, height: 1)
        cashTextField.layer.shadowOpacity = 1.0
        cashTextField.delegate = self
        
        slider.addTarget(self, action: #selector(updateCashValue), for: .valueChanged)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: nil)
        cancelButton.tintColor = UIColor.theme.gold
        let navigationFont = UIFont(name: "Montserrat Medium", size: 24)
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.theme.gold, NSAttributedString.Key.font: navigationFont!], for: .normal)
        self.navigationItem.backBarButtonItem = cancelButton
        
        rain(with: UIImage(named: "dollar_particle.png")!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if !Currency.isIntableFor(num: Currency.dollarValue, in: Currency.defaultCurrencies[0]) {
            Currency.selectedCurrency = Currency.defaultCurrencies[0]
            Currency.dollarValue = 1000
            updateView()
        }
        subscribeToKeybordNotifications()
        subscribeToBackgroundNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        unsubscribeToBackgroundNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playBarButton.pulse()
        
    }
    
    @IBAction func MenuAction(_ sender: UIBarButtonItem){
        self.navigationItem.backBarButtonItem?.title = "Back"
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    
    func setupSlider(slider: CircularSlider){
        slider.minimumValue = 0
        slider.maximumValue = 10000
        slider.diskColor = .clear
        slider.trackFillColor = UIColor.theme.main
        slider.thumbRadius = 16
        slider.trackColor = UIColor.theme.gray
        slider.backtrackLineWidth = 6
        slider.lineWidth = 14
        slider.endThumbStrokeColor = UIColor.theme.main
        slider.endThumbTintColor = UIColor.theme.gold
        slider.thumbLineWidth = 7
        slider.endPointValue = 1000
        slider.endThumbStrokeHighlightedColor = UIColor.theme.main
        slider.backgroundColor = .clear
    }
    
    func updateSlider(num: Int){
        Currency.dollarValue = Int(Double(num) * Currency.selectedCurrency.ratio)
        slider.endPointValue = num < Int(slider.maximumValue) ? CGFloat(num) : slider.maximumValue - 1
    }
    
    func rain(with image: UIImage){
        let emitter = RainEmitter.get(with: image)
        emitter.emitterPosition = CGPoint(x: view.frame.width/2, y: -20)
        emitter.emitterSize = CGSize(width: view.frame.width*2, height: 2)
        let newView = UIView()
        newView.layer.addSublayer(emitter)
        view.addSubview(newView)
        view.sendSubviewToBack(newView)
    }
    
    @objc func updateCashValue(){
        let newValue = Int(slider.endPointValue)
        Currency.dollarValue = Int(Double(newValue)*Currency.selectedCurrency.ratio)
        cashTextField.text = Currency.selectedCurrency.sign + "\(newValue)"
    }
    
    @objc func addAnimations(){
        playBarButton.pulse()
    }
    
    
    // MARK: Delegate Functions
    
    func updateView() {
        let convertedVal = Int(Double(Currency.dollarValue) / Currency.selectedCurrency.ratio)
        cashTextField.text = Currency.selectedCurrency.sign + "\(convertedVal)"
        slider.maximumValue = CGFloat(10000/Currency.selectedCurrency.ratio)
        slider.endPointValue = convertedVal < Int(slider.maximumValue) ? CGFloat(convertedVal) : slider.maximumValue - 1
    }
    
    func updateBackButton(){
        self.navigationItem.backBarButtonItem?.title = "Cancel"
    }
    
    
    // MARK: Segues
    
    @objc func presentARVC(){
        if (Currency.isRenderableFor(maxcount: 100000)){
            self.navigationItem.backBarButtonItem?.title = "Return"
            let vc = storyboard?.instantiateViewController(withIdentifier: "ARViewController") as! ARViewController
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "AlertStoryboard", bundle: .main)
            let vc = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
            
            vc.bodyText = "I know you are a wealthy one, but this is too much money to rain my dear, try something more modest"
            vc.titleText = "Ouch!"
            vc.buttonText = "Fine"
            present(vc, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        cashTextField.resignFirstResponder()
        if segue.identifier == "containerBanknoteSegue" {
            banknoteVC = segue.destination as? BanknoteViewController
            banknoteVC!.banknoteViewControllerDelegate = self
        } else if segue.identifier == "ARSceneSegue"{
            self.navigationItem.backBarButtonItem?.title = "Return"
        } else {
            self.navigationItem.backBarButtonItem?.title = "Back"
        }
    }

}


extension SelectionViewController: UITextFieldDelegate {
    
    
    // MARK: TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        let modifiedText = newText.replacingOccurrences(of: Currency.selectedCurrency.sign, with: "")
        
        guard let num = Int(modifiedText) else {
            if (modifiedText == ""){
                textField.text = Currency.selectedCurrency.sign
                updateSlider(num: 0)
            }
            return false
        }
        
        guard Currency.isIntableFor(num: num, in: Currency.selectedCurrency) else {
            return false
        }
        
        textField.text = Currency.selectedCurrency.sign + "\(num)"
        updateSlider(num: num)
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text == Currency.selectedCurrency.sign){
            textField.text = Currency.selectedCurrency.sign + "0"
            Currency.dollarValue = 0
        }
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: Keyboard Notifications
    
    func subscribeToKeybordNotifications(){
        
        //Initiation of notification observation
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        //Removes this control view as observer for notifications
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {slider.isEnabled = false}
    
    @objc func keyboardWillHide(_ notification: Notification) {slider.isEnabled = true}
    
    // Enables hiding keyboard on touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: Background Notifications
    
    func subscribeToBackgroundNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(addAnimations), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func unsubscribeToBackgroundNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
}

