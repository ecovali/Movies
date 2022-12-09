//
//  PopMoviesHTTPService.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PopMoviesHTTPService {
    
    struct Constants {
        static let page = "page"
    }
    
    private let apiResquests: APIRequests
    private let coreDataService: MoviesCoreDataService
    
    init(apiResquests: APIRequests, coreDataService: MoviesCoreDataService) {
        self.apiResquests = apiResquests
        self.coreDataService = coreDataService
    }
    
    func getPopularMovies(page: Int) -> Single<[Movie]> {
        return apiResquests.popularMovies(params: [Constants.page: page])
            .map { response -> [Movie] in  
                return response.movies
            }
            .flatMap { [weak self] movies in
                guard page == 1 else { return .just(movies) }
            
                return (self?.coreDataService.removeAllPages() ?? .just(()))
                .map { movies }
            }
            .flatMap { [weak self] movies in
                (self?.coreDataService.addMoviesPage(movies, page: page) ?? .just(()))
                .map { movies }
            }
    }
}
