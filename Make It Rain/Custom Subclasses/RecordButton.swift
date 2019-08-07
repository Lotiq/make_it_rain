//
//  RecordButton.swift
//  Make It Rain
//
//  Created by Timothy on 6/15/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation
import UIKit

@objc public enum RecordButtonState : Int {
    case ready, idle
}

@objc public enum PlayState: Int {
    case playing, idle
}

@objc protocol RecordButtonDelegate {
    @objc optional func RecordButtonStartedRecording()
    @objc optional func RecordButtonFinished()
}

@objc open class RecordButton : UIButton {
    
    open var buttonColor: UIColor! = UIColor.theme.gray{
        didSet {
            circleLayer.backgroundColor = buttonColor.cgColor
            circleBorder.borderColor = buttonColor.cgColor
        }
    }
    open var progressColor: UIColor!  = UIColor.theme.gold {
        didSet {
            gradientMaskLayer.colors = [progressColor.cgColor, progressColor.cgColor]
        }
    }
    
    /// Closes the circle and hides when the RecordButton is finished
    open var closeWhenFinished: Bool = false
    
    /// Max duration of the recording
    open var maxDuration: CGFloat = 15
    
    /// Min duration of the recording to be successful
    open var minDuration: CGFloat = 3
    
    /// Delegate
    weak var delegate: RecordButtonDelegate?
    
    open var buttonState : RecordButtonState = .idle {
        didSet {
            switch buttonState {
            case .idle:
                currentProgress = 0
                setProgress(0)
                setRecording(false)
            case .ready:
                setRecording(true)
            }
        }
        
    }
    
    open var playState : PlayState = .idle {
        didSet {
            switch playState {
            case .playing:
                changed(playing: true)
            case .idle:
                changed(playing: false)
            }
        }
    }
    
    fileprivate var circleLayer: CALayer!
    fileprivate var circleBorder: CALayer!
    fileprivate var progressLayer: CAShapeLayer!
    fileprivate var gradientMaskLayer: CAGradientLayer!
    fileprivate var currentProgress: CGFloat! = 0
    fileprivate var progressTimer = Timer()
    
    
    override public init(frame: CGRect) {
        
        super.init(frame: frame)
        self.addTarget(self, action: #selector(RecordButton.didTouchDown), for: .touchDown)
        
        self.drawButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(RecordButton.didTouchDown), for: .touchDown)
        
        self.drawButton()
    }
    
    
    fileprivate func drawButton() {
        
        self.backgroundColor = UIColor.clear
        let layer = self.layer
        circleLayer = CALayer()
        circleLayer.backgroundColor = buttonColor.cgColor
        let size: CGFloat = self.frame.size.width / 1.12 / 1.5
        circleLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer.position = CGPoint(x: self.frame.midX,y: self.frame.midY)
        circleLayer.cornerRadius = size / 2
        layer.insertSublayer(circleLayer, at: 0)
        
        
        circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 1
        circleBorder.borderColor = buttonColor.cgColor
        circleBorder.bounds = CGRect(x: 0, y: 0, width: (self.frame.size.width - 3)/1.12, height: (self.frame.size.height - 3)/1.12)
        circleBorder.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleBorder.position = CGPoint(x: self.frame.midX,y: self.frame.midY)
        circleBorder.cornerRadius = circleBorder.bounds.width / 2
        layer.insertSublayer(circleBorder, at: 0)
 
        
        let startAngle: CGFloat = CGFloat(Double.pi) + CGFloat(Double.pi/2)
        let endAngle: CGFloat = CGFloat(Double.pi) * 3 + CGFloat(Double.pi/2)
        //let centerPoint: CGPoint = CGPoint(x: self.frame.size.width / 1.12 / 2, y: self.frame.size.height / 1.12 / 2)
        let centerPoint: CGPoint = CGPoint(x: self.frame.midX,y: self.frame.midY)
        //let centerPoint: CGPoint = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        gradientMaskLayer = self.gradientMask()
        progressLayer = CAShapeLayer()
        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - 1.5, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.lineWidth = 3.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        
        gradientMaskLayer.mask = progressLayer
        layer.insertSublayer(gradientMaskLayer, at: 1)
        
    }
    
    fileprivate func setRecording(_ recording: Bool) {
        
        if (recording) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.enableAllOrientations = false
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.enableAllOrientations = true
        }
        
        let duration: TimeInterval = 0.15
        circleLayer.contentsGravity = .center
        circleBorder.contentsGravity = .center
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = recording ? 1 : 1.12
        scale.toValue = recording ? 1.12 : 1
        scale.duration = duration
        scale.fillMode = .forwards
        scale.isRemovedOnCompletion = false
        
        let color = CABasicAnimation(keyPath: "backgroundColor")
        color.duration = duration
        color.fillMode = .forwards
        color.isRemovedOnCompletion = false
        color.toValue = recording ? progressColor.cgColor : buttonColor.cgColor
        
        let circleAnimations = CAAnimationGroup()
        circleAnimations.isRemovedOnCompletion = false
        circleAnimations.fillMode = .forwards
        circleAnimations.duration = duration
        circleAnimations.animations = [scale, color]
        
        let borderColor: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColor.duration = duration
        borderColor.fillMode = .forwards
        borderColor.isRemovedOnCompletion = false
        borderColor.toValue = recording ? UIColor.white.cgColor : buttonColor.cgColor
        
        let borderScale = CABasicAnimation(keyPath: "transform.scale")
        borderScale.fromValue = recording ? 1 : 1.12
        borderScale.toValue = recording ? 1.12 : 1
        borderScale.duration = duration
        borderScale.fillMode = .forwards
        borderScale.isRemovedOnCompletion = false
        
        let borderAnimations = CAAnimationGroup()
        borderAnimations.isRemovedOnCompletion = false
        borderAnimations.fillMode = .forwards
        borderAnimations.duration = duration
        borderAnimations.animations = [borderColor, borderScale]
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = recording ? 0.0 : 1.0
        fade.toValue = recording ? 1.0 : 0.0
        fade.duration = duration
        fade.fillMode = .forwards
        fade.isRemovedOnCompletion = false
        
        circleLayer.add(circleAnimations, forKey: "circleAnimations")
        progressLayer.add(fade, forKey: "fade")
        circleBorder.add(borderAnimations, forKey: "borderAnimations")
        
    }
    
    fileprivate func gradientMask() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.0, 1.0]
        let topColor = progressColor
        let bottomColor = progressColor
        gradientLayer.colors = [topColor?.cgColor as Any, bottomColor?.cgColor as Any]
        return gradientLayer
    }
    
    override open func layoutSubviews() {
        
        circleBorder.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleBorder.position = CGPoint(x: self.frame.midX,y: self.frame.midY - 1)
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer.position = CGPoint(x: self.frame.midX,y: self.frame.midY - 1)
        
        super.layoutSubviews()
    }
    
    @objc open func updateProgress(){
        currentProgress = currentProgress + (CGFloat(0.05) / maxDuration)
        self.setProgress(currentProgress)
        
        if currentProgress >= 1 {
            progressTimer.invalidate()
            self.delegate?.RecordButtonFinished?()
        }
    }
    
    open func changed(playing: Bool){
        guard playing else {return}
        
        if (self.buttonState == .ready) {
            self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            self.delegate?.RecordButtonStartedRecording?()
        }
    }
    
    @objc open func didTouchDown(){
        
        if self.playState == .playing {
            
            guard self.buttonState == .ready else {
                self.buttonState = .ready
                self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
                self.delegate?.RecordButtonStartedRecording?()
                return
            }
            
            if currentProgress < minDuration/maxDuration {
                progressTimer.invalidate()
                setProgress(currentProgress)
                self.buttonState = .idle
            } else {
                progressTimer.invalidate()
                self.delegate?.RecordButtonFinished?()
            }
            
            
        } else if self.playState == .idle {
            
            //Switches between ready to record and idle
            if (self.buttonState == .ready) {
                self.buttonState = .idle
            } else if (self.buttonState == .idle) {
                self.buttonState = .ready
            }
        }
    }
    
    /**
     Set the relative length of the circle border to the specified progress
     
     - parameter newProgress: the relative lenght, a percentage as float.
     */
    open func setProgress(_ newProgress: CGFloat) {
        currentProgress = newProgress
        progressLayer.strokeEnd = newProgress
    }
    
    
}
