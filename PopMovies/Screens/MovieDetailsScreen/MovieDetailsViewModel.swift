//
//  MovieDetailsViewModel.swift
//  PopMovies
//
//  Created by ecovali on 3/9/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class MovieDetailsViewModel {
    
    struct Messages {
        static let noInternetConnectionTitle = "No internet connection"
        static let noInternetConnectionMessage = "Please check you internet connection and try again."
        static let tryAgainButton = "Try again"
         static let cancelButton = "Cancel"
        static let loadVideosTitle = "Load videos title."
    }
    
    // Coordinator
    let finish = PublishSubject<Void>()
    
    // Input
    let attach = PublishSubject<Void>()
    let didSelect = PublishSubject<Video>()
    let relaod = PublishSubject<Void>()
    
    // Output
    let movie = BehaviorSubject<Movie?>(value: nil)
    let loading = BehaviorSubject<(type: LoadingType, state: Bool)?>(value: nil)
    let displayVideos = BehaviorSubject<[AnimatableSectionModel<Int, Video>]>(value: [])
    let alerts = PublishSubject<InformalViewData>()
    let error = BehaviorSubject<InformalViewData?>(value: nil)
    
    public var countOfVideos: Int {
        guard let value = try? allVideos.value() else { return Int() }
        return value.count
    }
    
    private let disposeBag = DisposeBag()
    private let httpService: MovieDetailsHTTPService
    private let allVideos = BehaviorSubject<[Video]>(value: [])
    private let coreDataService: MoviesCoreDataService
    
    init(movie: Movie, httpService: MovieDetailsHTTPService, coreDataService: MoviesCoreDataService) {
        self.httpService = httpService
        self.movie.onNext(movie)
        self.coreDataService = coreDataService
        
        bind()
    }
    
    private func bind() {
        
        allVideos.map {
            [AnimatableSectionModel(model: 0, items: $0)]
        }
        .bind(to: displayVideos)
        .disposed(by: disposeBag)
        
        Observable
            .of(attach.map { LoadingType.loading },
                relaod.map { LoadingType.reloading })
            .merge()
            .withLatestFrom(movie, resultSelector: { (type: $0, movie: $1) })
            .subscribe(onNext: { [weak self] value in
                if let movie = value.movie {
                    self?.error.onNext(nil)
                    self?.getVideosBy(type: value.type, movie: movie)
                }
            })
            .disposed(by: disposeBag)
                
        didSelect
            .subscribe(onNext: { [weak self] video in
                self?.handleSelection(video)
            })
            .disposed(by: disposeBag)
        
        ReachabilityService.shared.onReachabilityRestore
            .subscribe(onNext: { [weak self] _ in
                self?.loading.onNext((type: .reloading, state: true))
                self?.relaod.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    private func handleSelection(_ video: Video) {
        if let link = video.watchUrl {
            UIApplication.shared.open(link)
        }
    }
    
    private func getVideosBy(type: LoadingType, movie: Movie) {
        
        loading.onNext((type: type, state: true))
        fetchVideos(for: movie)
            .subscribe(onSuccess: { [weak self] videos in
                self?.loading.onNext((type: type, state: false))
                self?.handle(videos, movie, type)
                
                self?.finish.onNext(())
                }, onError: { [weak self] error in
                    self?.loading.onNext((type: type, state: false))
                    self?.handle(error, movie, type)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchVideos(for movie: Movie) -> Single<[Video]> {
        let isReachabile = ReachabilityService.shared.isReachable
        if isReachabile {
            return httpService.getVideosByMovie(id: movie.id)
        } else {
            return coreDataService.fetchVideos(for: movie.id)
        }
    }
    
    private func handle(_ newVideos: [Video], _ movie: Movie, _ type: LoadingType) {
        allVideos.onNext(newVideos)
        
        let isReachabile = ReachabilityService.shared.isReachable
        if newVideos.isEmpty && !isReachabile {
            
            let mainAction = InformalViewAction(title: Messages.tryAgainButton) { [weak self] in
                self?.getVideosBy(type: type, movie: movie)
            }

            self.alerts.onNext(InformalViewData(Messages.noInternetConnectionTitle,
                                                message: Messages.noInternetConnectionMessage,
                                                mainAction: mainAction,
                                                dissmisAction: InformalViewAction(title: Messages.cancelButton)))
        }
    }
    
    private func handle(_ error: Error, _ movie: Movie, _ type: LoadingType) {
        
        let mainAction = InformalViewAction(title: Messages.tryAgainButton) { [weak self] in
            self?.getVideosBy(type: type, movie: movie)
        }
        
        self.error.onNext(InformalViewData(Messages.loadVideosTitle,
                                           message: error.localizedDescription,
                                           mainAction: mainAction,
                                           dissmisAction: InformalViewAction(title: Messages.cancelButton)))
    }
}

private extension Video {
    var watchUrl: URL? {
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }
}
