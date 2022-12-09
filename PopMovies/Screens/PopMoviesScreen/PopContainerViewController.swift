//
//  PopContainerViewController.swift
//  PopMovies
//
//  Created by ecovali on 3/10/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit

class PopContainerViewController: UIViewController {
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    var leftNaviagtionController: UINavigationController? {
        didSet {
            setupLeftView()
        }
    }
    var rightNaviagtionController: UINavigationController? {
        didSet {
            setupRightView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationControllers()
    }
    
    private func setupLeftView() {
        if let leftNaviagtionController = leftNaviagtionController, let leftView = leftView {
            leftView.addSubview(leftNaviagtionController.view)
            leftView.addContentConstraintsToView(leftNaviagtionController.view)
            addChild(leftNaviagtionController)
        }
    }
    
    private func setupRightView() {
        if let rightNaviagtionController = rightNaviagtionController, let rightView = rightView {
            rightView.addSubview(rightNaviagtionController.view)
            rightView.addContentConstraintsToView(rightNaviagtionController.view)
            addChild(rightNaviagtionController)
        }
    }
    
    private func setupNavigationControllers() {
        setupLeftView()
        setupRightView()
    }
    
}
