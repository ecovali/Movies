//
//  UIView+Identifire.swift
//  PopMovies
//
//  Created by ecovali on 3/6/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var identifier: String {
        return String(describing: type(of: self))
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}

extension UIViewController {
    
    var identifier: String {
        return String(describing: type(of: self))
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}

extension UIView {
    
    func setBottomShadow() {
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 1
    }
    
    func setTopShadow(color: UIColor = UIColor.lightGray) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 2
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, radius: CGFloat = 1, cornerRadius: CGFloat = 0) {
        layer.masksToBounds = false
        
        layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: bounds.origin.x,
                                                            y: bounds.origin.y,
                                                            width: bounds.width,
                                                            height: bounds.height),
                                        cornerRadius: cornerRadius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = radius
    }
}

extension UIView {
    
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set(newWidth) {
            frame.size.width = newWidth
        }
    }
    
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set(newHeight) {
            frame.size.height = newHeight
        }
    }
    
    var maxY: CGFloat {
        return yOrigin + frame.size.height
    }
    
    var maxX: CGFloat {
        return xOrigin + frame.size.width
    }
    
    var size: CGSize {
        get {
            return frame.size
        }
        set(newSize) {
            frame.size = newSize
        }
    }
    
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set(newOrigin) {
            frame.origin = newOrigin
        }
    }
    
    var bottomEdge: CGFloat {
        return frame.origin.y + frame.size.height
    }
    
    var rightEdge: CGFloat {
        get {
            return frame.origin.x + width
        }
        set (newRightEdge) {
            frame.origin.x = newRightEdge - width
        }
    }
    
    var xOrigin: CGFloat {
        get {
            return frame.origin.x
        }
        set(newXOrigin) {
            frame.origin.x = newXOrigin
        }
    }
    
    var yOrigin: CGFloat {
        get {
            return frame.origin.y
        }
        set(newYOrigin) {
            frame.origin.y = newYOrigin
        }
    }
    
    var xCenter: CGFloat {
        get {
            return center.x
        }
        set(newXCenter) {
            center.x = newXCenter
        }
    }
    
    var yCenter: CGFloat {
        get {
            return center.y
        }
        set(newYCenter) {
            self.center.y = newYCenter
        }
    }
    
    var contentCenter: CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }
}

extension UIView {
    
    func setCornerRadius(radius: CGFloat, corners: UIRectCorner = [.topLeft, .bottomLeft, .bottomRight, .topRight]) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}

@IBDesignable extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var isRound: Bool {
        set {
            layer.cornerRadius = height / 2
            clipsToBounds = true
            _ = newValue
        }
        get {
            return layer.cornerRadius == (height / 2)
        }
    }
}

extension UITextField {
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string: placeholder != nil ? placeholder ?? "" : "",
                                                            attributes: [NSAttributedString.Key.foregroundColor: newValue ?? UIColor.white,
                                                                         NSAttributedString.Key.font: font ?? UIFont()])
        }
    }
}

extension UIView {
    
    func setVertyicalGradientWith(firstColor: UIColor, secondColor: UIColor, center: CGFloat) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.locations = [0.0, center, 1.0] as [NSNumber]
        gradientLayer.colors = [firstColor.cgColor,
                                secondColor.cgColor]
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIView {
    
    func setHorizontalGradientWith(firstColor: UIColor, secondColor: UIColor) {
        let horizontalGradient = "HorizontalGradient"
        layer.sublayers?
            .filter { $0.name == horizontalGradient }
            .forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.masksToBounds = true
        gradientLayer.name = horizontalGradient
        gradientLayer.frame = bounds
        gradientLayer.colors = [firstColor.cgColor,
                                secondColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIView {
    
    func addSubviewToFill(_ view: UIView) {
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    }
    
    func addSubview(_ view: UIView, top: CGFloat, bottom: CGFloat, leading: CGFloat, trailing: CGFloat) {
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.topAnchor, constant: top).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: bottom).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailing).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading).isActive = true
    }
    
    func addSubview(_ view: UIView, top: CGFloat? = nil, bottom: CGFloat? = nil, leading: CGFloat? = nil, trailing: CGFloat? = nil, zIndex: Int? = nil) {
        if let index = zIndex {
            self.insertSubview(view, at: index)
        } else {
            self.addSubview(view)
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: top).isActive = true
        }
        
        if let bottom = bottom {
            view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: bottom).isActive = true
        }
        
        if let trailing = trailing {
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailing).isActive = true
        }
        
        if let leading = leading {
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading).isActive = true
        }
    }
}

extension UIView {
    
    func addContentConstraintsToView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
