//
//  PopMoviesViewModel.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class PopMoviesViewModel {
    
    struct Messages {
        static let noInternetConnectionTitle = "No internet connection"
        static let noInternetConnectionMessage = "Please check you internet connection and try again."
        static let tryAgainButton = "Try again"
        static let cancelButton = "Cancel"
        static let noMoviesTitle = "No Movies"
        static let noMoviesMessage = "Currently we cannot find any one movie."
        static let cannotNotLoadNextPageMessage = "Cannot load next movies page, beacuse no internet connection."
        static let loadMoviesTitle = "Load movies"
    }
    
    // Coordinator
    let showDetails = PublishSubject<Movie>()
    
    // Input
    let attach = PublishSubject<Void>()
    let relaod = PublishSubject<Void>()
    let loadMore = PublishSubject<Void>()
    let didSelect = PublishSubject<Movie>()
    
    // Output
    let displayMovies = BehaviorSubject<[AnimatableSectionModel<Int, Movie>]>(value: [])
    let loading = BehaviorSubject<(type: LoadingType, state: Bool)?>(value: nil)
    let alerts = PublishSubject<InformalViewData>()
    let error = BehaviorSubject<InformalViewData?>(value: nil)
    let orientation = BehaviorSubject<UIDeviceOrientation>(value: .portrait)
    
    private let disposeBag = DisposeBag()
    private let httpService: PopMoviesHTTPService
    private let page = BehaviorSubject<Int>(value: 0)
    private let allMovies = BehaviorSubject<[Movie]>(value: [])
    private let coreDataService: MoviesCoreDataService
    
    init(httpService: PopMoviesHTTPService, coreDataService: MoviesCoreDataService) {
        self.httpService = httpService
        self.coreDataService = coreDataService
        
        bind()
    }
    
    private func bind() {
        
        let reloadTriger = relaod.map { LoadingType.reloading }
            .do(onNext: { [weak self] _ in
                self?.page.onNext(0)
            })
        
        Observable
            .of(reloadTriger,
                attach.map { LoadingType.loading },
                loadMore.map { LoadingType.loadMore })
            .merge()
            .withLatestFrom(allMovies, resultSelector: { (type: $0, currentMovies: $1) })
            .subscribe(onNext: { [weak self] value in
                self?.error.onNext(nil)
                self?.loadMovies(type: value.type, currentMovies: value.currentMovies)
            })
            .disposed(by: disposeBag)
        
        allMovies.map {
            [AnimatableSectionModel(model: 0, items: $0)]
        }
        .bind(to: displayMovies)
        .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIDevice.orientationDidChangeNotification)
            .observeOn(MainScheduler.instance)
            .map { ($0.object as? UIDevice)?.orientation ?? .portrait }
            .bind(to: orientation)
            .disposed(by: disposeBag)
        
        didSelect
            .bind(to: showDetails)
            .disposed(by: disposeBag)
        
        ReachabilityService.shared.onReachabilityRestore
            .subscribe(onNext: { [weak self] _ in
                    self?.relaod.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    private func loadMovies(type: LoadingType, currentMovies: [Movie]) {
        
        loading.onNext((type: type, state: true))
        
        (type == .loadMore ? page : .just(0))
            .map { $0 + 1 }
            .take(1)
            .flatMap { [weak self] page in
                (self?.fetchMovies(for: page) ?? .just([]))
                    .map { (newMovies: $0, page: page) }
            }
            .subscribe(onNext: { [weak self] value in
                self?.loading.onNext((type: type, state: false))
                if !value.newMovies.isEmpty {
                    self?.page.onNext(value.page + 1)
                }
                 self?.handle(value.newMovies, currentMovies, type)
            }, onError: { [weak self] error in
                self?.loading.onNext((type: type, state: false))
                self?.handle(error, currentMovies, type)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchMovies(for page: Int) -> Single<[Movie]> {
        let isReachabile = ReachabilityService.shared.isReachable
        if isReachabile {
            return httpService.getPopularMovies(page: page)
        } else {
            return coreDataService.fetchMoviesFor(page)
        }
    }
    
    private func handle(_ newMovies: [Movie], _ currentMovies: [Movie], _ type: LoadingType) {
        let finalMovies = (type == .reloading ? [] : currentMovies) + newMovies
        allMovies.onNext(finalMovies)
        
        let isReachabile = ReachabilityService.shared.isReachable
        if !currentMovies.isEmpty && newMovies.isEmpty && !isReachabile {
            
            let mainAction = InformalViewAction(title: Messages.tryAgainButton) { [weak self] in
                self?.loadMovies(type: type, currentMovies: currentMovies)
            }

            self.alerts.onNext(InformalViewData(Messages.noInternetConnectionTitle,
                                                message: Messages.noInternetConnectionMessage,
                                                mainAction: mainAction,
                                                dissmisAction: InformalViewAction(title: Messages.cancelButton)))
        }
        guard finalMovies.isEmpty else { return }
        
        let title = isReachabile ? Messages.noMoviesTitle : Messages.noInternetConnectionTitle
        let message = isReachabile ? Messages.noMoviesMessage : Messages.noInternetConnectionMessage
        let viewData = InformalViewData(title, message: message)
        error.onNext(viewData)
    }

    private func handle(_ error: Error, _ currentMovies: [Movie], _ type: LoadingType) {
        
        let mainAction = InformalViewAction(title: Messages.tryAgainButton) { [weak self] in
            self?.loadMovies(type: type, currentMovies: currentMovies)
        }
        
        self.error.onNext(InformalViewData(Messages.loadMoviesTitle,
                                           message: error.localizedDescription,
                                           mainAction: mainAction))
    }
}
