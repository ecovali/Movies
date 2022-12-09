//
//  AppearanceHelper.swift
//  PopMovies
//
//  Created by ecovali on 3/9/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit

class MNavigationBar: UINavigationBar {}
    
class AppearanceHelper {
    struct Constants {
        static let backButtonImageTitle = "back_btn"
        static let titleSize = CGFloat(18.0)
        static let tabBarItemSize = CGFloat(10.0)
        static let positionAdjustment = UIOffset(horizontal: CGFloat(0.0), vertical: CGFloat(-100.0))
    }
    
    static func setupUIAppearance() {
        MNavigationBar.setupUIAppearance()
        UIBarButtonItem.setupUIAppearance()
    }
}

private extension MNavigationBar {
    
    static func setupUIAppearance() {
        
        let apperance = MNavigationBar.appearance()
        apperance.tintColor = .white
        
        apperance.shadowImage = UIImage()
        apperance.barTintColor = UIColor(patternImage: UIImage())
        
        apperance.isTranslucent = false
        apperance.backgroundColor = .clear
        apperance.barTintColor = .clear
        apperance.setBackgroundImage(Constants.Color.darkGray.getImage(), for: .default)
        
        let font = UIFont.boldSystemFont(ofSize: 20)
        let image = UIImage(named: AppearanceHelper.Constants.backButtonImageTitle)
        
        apperance.backIndicatorImage = image
        apperance.backIndicatorTransitionMaskImage = image
        
        apperance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: font
        ]
    }
}

private extension UIBarButtonItem {
    static func setupUIAppearance() {
        let apperance = UIBarButtonItem.appearance()
        
        apperance.setBackButtonTitlePositionAdjustment(AppearanceHelper.Constants.positionAdjustment, for: .compact)
        apperance.setBackButtonTitlePositionAdjustment(AppearanceHelper.Constants.positionAdjustment, for: .default)
    }
}

private extension UIColor {
    func getImage() -> UIImage {
        let size = CGSize(width: 1, height: 1)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}
