//
//  AnimatedDotsLoadingView.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//
import Foundation
import UIKit

class AnimatedDotsLoadingView: UIView {
    
    @IBOutlet weak var dotsContainer: UIStackView!
    
    private var gradientLayer = CAGradientLayer()
    private var dotsColorsMap = [Int: Bool]()
    private var currentAnimatedDot = 1
    private var repeater: Repeater?
    
    var dotsCount: Int = 7 {
        didSet {
            resetDots()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialDotViewsSetup()
    }
    
    deinit {
        repeater?.removeAllObservers(thenStop: true)
        repeater = nil
    }
    
    func stopAnimation() {
        repeater?.removeAllObservers(thenStop: true)
        repeater = nil
        removeFromSuperview()
    }
    
    private func initialDotViewsSetup() {
        for i in 0..<7 {
            guard let view = viewWithTag(i + 1) else { break }
            view.layer.opacity = 0
            view.backgroundColor = #colorLiteral(red: 0.1882352941, green: 0.3098039216, blue: 0.9960784314, alpha: 1)
            dotsColorsMap[i + 1] = true
            view.layer.cornerRadius = view.frame.height / 2
            view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
    }
    
    @objc private func animateCurrentDot() {
        guard let dotView = dotsContainer.viewWithTag(currentAnimatedDot) as? DotView else { return }
        dotView.backgroundColor = dotView.isFirstColor ? #colorLiteral(red: 0.1882352941, green: 0.3098039216, blue: 0.9960784314, alpha: 1) : UIColor.white
        dotView.isFirstColor.toggle()
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
            dotView.layer.opacity = 1
            dotView.transform = CGAffineTransform.identity
            self.currentAnimatedDot = self.currentAnimatedDot == self.dotsCount ? 1 : self.currentAnimatedDot + 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.4, animations: {
                dotView.layer.opacity = 0
                dotView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            })
        })
    }
    
    private func resetDots() {
        dotsContainer.arrangedSubviews.forEach({
            $0.isHidden = $0.tag > dotsCount
        })
        repeater = Repeater.every(.seconds(0.15)) { [weak self] _ in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.animateCurrentDot()
            }
        }
    }
}

class DotView: UIView {
    var isFirstColor = true
}
