//
//  Emitter.swift
//  Make It Rain
//
//  Created by Timothy on 5/5/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation
import UIKit

class RainEmitter {
    static func get(with image: UIImage) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterShape = .line
        emitter.emitterCells = generateCells(with: image)
        
        return emitter
    }
    
    static func generateCells(with image: UIImage) -> [CAEmitterCell]{
        var cells = [CAEmitterCell]()
        
        let cell = CAEmitterCell()
        cell.contents = image.cgImage
        cell.birthRate = 0.8
        cell.lifetime = 50
        cell.velocity = 25
        cell.emissionLongitude = (180*(.pi/180))
        cell.emissionRange = (75*(.pi/180))
        cell.scale = 0.3
        cell.scaleRange = 0.3
        cell.spin = 0.1
        cell.spinRange = 0.2
        
        cells.append(cell)
        return cells
    }
}
