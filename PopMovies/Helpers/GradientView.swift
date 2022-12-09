//
//  GradientView.swift
//  PopMovies
//
//  Created by ecovali on 3/9/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class GradientView: UIView {

    @IBInspectable var startColor: UIColor = UIColor.black.withAlphaComponent(0.75) {
        didSet {
            updateColors()
        }
    }
    @IBInspectable var endColor: UIColor = UIColor.white.withAlphaComponent(0.25) {
        didSet {
            updateColors()
        }
    }
    @IBInspectable var startLocation: Double = 0.05 {
        didSet {
            updateLocations()
        }
    }
    @IBInspectable var endLocation: Double = 0.95 {
        didSet {
            updateLocations()
        }
    }
    @IBInspectable var horizontalMode: Bool = false {
        didSet {
            updatePoints()
        }
    }
    @IBInspectable var diagonalMode: Bool = false {
        didSet {
            updatePoints()
        }
    }

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as? CAGradientLayer ?? CAGradientLayer() }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}
