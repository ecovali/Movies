//
//  PosterImageView.swift
//  PopMovies
//
//  Created by ecovali on 3/9/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

enum PosterViewType {
  case poster
  case backdrop
}

private enum PosterSize: CGFloat {
    case w92 = 92.0
    case w154 = 154.0
    case w185 = 185.0
    case w342 = 342.0
    case w500 = 500.0
    case w780 = 780.0
}

private enum BackdropSize: CGFloat {
    case w185 = 185.0
    case w300 = 300.0
    case w780 = 780.0
    case w1280 = 1280.0
}

class PosterImageView: UIImageView {
    
    struct Constats {
        static let placeholder = "avatar_icon_small"
    }
    
    // Input
    let movie = PublishSubject<Movie>()
    let type = BehaviorSubject<PosterViewType>(value: .poster)
    
    private var posterSize: PosterSize = .w185
    private var backdropSize: BackdropSize = .w185
    
    static private var posterSizes: [PosterSize] {
        return [.w92, .w154, .w185, .w342, .w500, .w780]
    }
    
    static private var backdropSizes: [BackdropSize] {
        return [.w185, .w300, .w780, .w1280]
    }
    
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
        bind()
    }
    
    private func setup() {
        setupPosterSize()
        setupbackdropSize()
        image = UIImage(named: Constats.placeholder)
    }
    
    private func setupPosterSize() {
        posterSize =
            PosterImageView.posterSizes.map { [$0: abs(pixelwidth - $0.rawValue)] }
            .min { $0.values.first ?? CGFloat() < $1.values.first ?? CGFloat() }?.keys.first ?? .w185
    }
    
    private func setupbackdropSize() {
        backdropSize =
            PosterImageView.backdropSizes.map { [$0: abs(pixelwidth - $0.rawValue)] }
            .min { $0.values.first ?? CGFloat() < $1.values.first ?? CGFloat() }?.keys.first ?? .w185
    }
    
    private func bind() {
        
        let value =
        Observable.combineLatest(type, movie,
                                 resultSelector: { (type: $0, movie: $1) })
        movie
            .withLatestFrom(value)
            .subscribe(onNext: { [weak self] value in
                switch value.type {
                case .poster:
                    self?.handleNew(value.movie.posterUrlBy(Int(self?.posterSize.rawValue ?? CGFloat())))
                case .backdrop:
                    self?.handleNew(value.movie.backdropUrlBy(Int(self?.backdropSize.rawValue ?? CGFloat())))
                    
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func handleNew(_ url: URL?) {
        setImage(with: url,
                 placeholder: UIImage(named: Constats.placeholder),
                 withLoadingIndicator: true)
    }
    
    var pixelwidth: CGFloat {
        return size.width
    }
}

private extension Movie {
    func posterUrlBy(_ width: Int) -> URL? {
        return URL(string: "https://image.tmdb.org/t/p/w\(width)" + posterPath)
    }
    func backdropUrlBy(_ width: Int) -> URL? {
        return URL(string: "https://image.tmdb.org/t/p/w\(width)" + backdropPath)
    }
}
