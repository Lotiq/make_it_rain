//
//  PulsingBarButtonItem.swift
//  Make It Rain
//
//  Created by Timothy on 5/16/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class PulsingBarButtonItem: UIBarButtonItem {
    
    var pulseLayers: [CAShapeLayer] = []
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func pulse() {
        guard let view = self.customView else {
            print("No Custom View Found")
            return
        }
        
        for i in 0..<3{
            if i < pulseLayers.count {
               pulseLayers[i].removeAllAnimations()
            }
            
            let circularPath = UIBezierPath(arcCenter: .zero, radius: view.frame.size.height/2, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            let pulseLayer = CAShapeLayer()
            pulseLayer.path = circularPath.cgPath
            pulseLayer.lineWidth = 2
            pulseLayer.fillColor = UIColor.clear.cgColor
            pulseLayer.opacity = 0
            view.layer.addSublayer(pulseLayer)
            pulseLayer.strokeColor = UIColor.themeColor.extra.cgColor
            pulseLayer.lineCap = .round
            pulseLayer.position = CGPoint(x: view.frame.width/2 , y: view.frame.height/2)
            //pulseLayers[i] = pulseLayer
            if i < pulseLayers.count {
                pulseLayers[i] = pulseLayer
            } else {
                pulseLayers.append(pulseLayer)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.addPulseAnimation(index: 0)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.9) {
                self.addPulseAnimation(index: 1)
                DispatchQueue.main.asyncAfter(deadline: .now()+1.1) {
                    self.addPulseAnimation(index: 2)
                }
            }
        }
    }
    
    func addPulseAnimation(index: Int){
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 5
        scaleAnimation.fromValue = 0
        scaleAnimation.toValue = 0.9
        scaleAnimation.repeatCount = 3
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.duration = 5
        opacityAnimation.fromValue = 0.9
        opacityAnimation.toValue = 0
        opacityAnimation.repeatCount = 3
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        let group = CAAnimationGroup()
        group.animations = [scaleAnimation,opacityAnimation]
        group.duration = 30
        group.repeatCount = .greatestFiniteMagnitude
        
        pulseLayers[index].add(group, forKey: "group")
    }
    
}
