//
//  Constants.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

enum LoadingType {
  case loading
  case reloading
  case loadMore
  case none
}

struct Constants {
    static let apiKeyValue = "a998316ea58d2658720b5e81f5607883"
    static let apiKey = "api_key"
    struct URLs {
        struct BaseURL {
            static let development = "https://api.themoviedb.org/3"
        }
        static let moviePopular = "/movie/popular"
        static let videos = "/movie/%@/videos"
        
    }
    struct Color {
        static let white = UIColor.hexStringToUIColor("#000000")
        static let green = UIColor.hexStringToUIColor("#009687")
        static let darkGray = UIColor.hexStringToUIColor("#191D1A")
    }
    struct DateFormats {
        static var movie: DateFormatter {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            return dateFormatter
        }
        static var year: DateFormatter {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            return dateFormatter
        }
    }
}
