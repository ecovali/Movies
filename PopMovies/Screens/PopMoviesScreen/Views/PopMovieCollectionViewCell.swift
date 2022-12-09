//
//  PopMovieCollectionViewCell.swift
//  PopMovies
//
//  Created by ecovali on 3/6/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Kingfisher

class PopMovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: PosterImageView!
    
    public func setup(movie: Movie) {
        imageView.movie.onNext(movie)
    }
}
