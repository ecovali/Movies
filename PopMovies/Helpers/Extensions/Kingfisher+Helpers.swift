//
//  Kingfisher+Helpers.swift
//  PopMovies
//
//  Created by ecovali on 3/6/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Kingfisher

extension UIImageView {
    
    var imageOptions: KingfisherOptionsInfo {
        let options: KingfisherOptionsInfo = [.cacheSerializer(DefaultCacheSerializer.default),
                                              .backgroundDecode,
                                              .originalCache(.default),
                                              .cacheOriginalImage,
                                              .transition(.fade(0.2)),
                                              .scaleFactor(UIScreen.main.scale)]
        return options
    }
    
    func setImage(with url: URL?, placeholder: UIImage? = nil, withLoadingIndicator: Bool = false) {
        guard let urlStr = url?.absoluteString, let url = URL(string: urlStr) else {
            image = placeholder
            return
        }
        
        var kf = self.kf
        kf.cancelDownloadTask()
        
        if withLoadingIndicator {
            kf.indicatorType = .activity
        }
        
        kf.setImage(with: url,
                    placeholder: placeholder,
                    options: imageOptions + [.onFailureImage(placeholder)],
                    progressBlock: nil)
        
        (kf.indicator?.view as? UIActivityIndicatorView)?.color = UIColor.white
    }
}
