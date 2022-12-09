//
//  Observable+Helpers.swift
//  BidiPass
//
//  Created by  Nicu Pradauta on 1/2/19.
//  Copyright © 2019 bidipass. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    
    func withPrevious(startWith first: E?) -> Observable<(E?, E?)> {
        return scan((first, first)) { ($0.1, $1) }
    }
}
