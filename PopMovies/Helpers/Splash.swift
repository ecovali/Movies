//
//  Splash.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit

class LoadingWindow: UIWindow {
    
    private var oldKeyWindow = UIWindow()
    
    override func makeKeyAndVisible() {
        if let windowValue = UIApplication.shared.keyWindow {
            oldKeyWindow = windowValue
            windowLevel = .alert
        }
        super.makeKeyAndVisible()
    }
    
    override func resignKey() {
        super.resignKey()
        self.oldKeyWindow.makeKey()
    }
}

class Splash {
    
    struct Constants {
        static let fadeAnimationDuration = Double(UINavigationController.hideShowBarDuration)
        static let launchScreen = "LaunchScreen"
    }
    
    static private var shared: Splash? = Splash()
    private var rootWindow: LoadingWindow?
    
    lazy private var storyboardName: String = {
        return Constants.launchScreen
    }()
    
    lazy private var rootViewController: UIViewController = {
        return UIViewController.initFromStoryboard(name: Constants.launchScreen) ?? UIViewController()
    }()
    
    lazy private var overlayView: UIView = {
        let overlayView = UIView(frame: screenBounds)
        overlayView.backgroundColor = .white
        return overlayView
    }()
    
    private var screenBounds: CGRect {
        return UIScreen.main.bounds
    }
    
    private func setupWindow() {
        self.rootWindow = LoadingWindow(frame: screenBounds)
        self.rootWindow?.alpha = 0.0
        self.rootWindow?.rootViewController = self.rootViewController
    }
    
    private func isShow() -> Bool {
        if let rootWindow = self.rootWindow {
            return rootWindow.alpha != CGFloat(0)
        }
        return false
    }
    
    private func prepareForAnimation(show: Bool, completion: @escaping () -> Void) {
        if show {
            setupWindow()
            rootWindow?.addSubview(overlayView)
            overlayView.layer.zPosition -= 1
        }
        
        if show {
            overlayView.layer.opacity = 0.0
        } else {
            overlayView.layer.opacity = 1.0
        }
        overlayView.layoutIfNeeded()
        if let rootWindow = rootWindow {
            if !rootWindow.isKeyWindow && show {
                rootWindow.makeKeyAndVisible()
            }
        }
        
        UIView.animate(withDuration: TimeInterval(Constants.fadeAnimationDuration), animations: { [weak self] in
            self?.rootWindow?.alpha = show ? 1.0 : 0.0
        }) { [weak self] _ in
            if !show {
                self?.rootWindow?.resignFirstResponder()
                self?.rootWindow = nil
            }
            completion()
            
        }
    }
    
    private func showLoading(animated: Bool, completion: @escaping () -> Void) {
        prepareForAnimation(show: true, completion: completion)
    }
    
    private func hideLoading(animated: Bool, completion: @escaping () -> Void) {
        prepareForAnimation(show: false, completion: completion)
    }
    
    static func showLoading(animated: Bool, completion: @escaping () -> Void) {
        shared?.showLoading(animated: animated, completion: completion)
    }
    static func hideLoading(animated: Bool, completion: @escaping () -> Void) {
        shared?.hideLoading(animated: animated, completion: completion)
    }
    
    static func isShow() -> Bool {
        return shared?.isShow() ?? false
    }
}
