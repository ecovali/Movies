//
//  ApplicationProtocol.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit

protocol ApplicationProtocol: class {
    func open(_ url: URL)
}

extension UIApplication: ApplicationProtocol {
    func open(_ url: URL) {
        open(url, options: [:], completionHandler: nil)
    }
}
