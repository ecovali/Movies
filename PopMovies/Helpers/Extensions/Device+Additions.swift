//
//  Device+Additions.swift
//  PopMovies
//
//  Created by ecovali on 3/10/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import Device

extension Device {
    static var isPadScreen: Bool {
        let size = Device.size()
        return
            .screen7_9Inch == size ||
            .screen9_7Inch == size  ||
            .screen10_2Inch == size  ||
            .screen10_5Inch == size  ||
            .screen11Inch == size  ||
            .screen12_9Inch == size
    }
}
