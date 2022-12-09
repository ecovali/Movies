//
//  StoryboardInitializable.swift
//  PopMovies
//
//  Created by ecovali on 3/6/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController: StoryboardInitializable {}

protocol StoryboardInitializable {
    static var identifier: String { get }
}

extension StoryboardInitializable where Self: UIViewController {

    static func initFromStoryboard(name: String? = nil) -> Self? {
        let storyboard = UIStoryboard(name: name ?? identifier, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? Self
    }
}
