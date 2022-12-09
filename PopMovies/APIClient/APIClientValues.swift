//
//  APIClientValues.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import SwiftyJSON

struct APIClientResponse {
    var data: Data
    var json: JSON?
}

enum APIClientProgressResponse {
    case complete(APIClientResponse)
    case progress(Double)
}
