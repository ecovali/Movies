//
//  UIScreen+Additions.swift
//  PopMovies
//
//  Created by ecovali on 3/6/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit

extension UIScreen {
  static var ratio: CGFloat {
    return UIScreen.main.bounds.width / 375
  }
}
