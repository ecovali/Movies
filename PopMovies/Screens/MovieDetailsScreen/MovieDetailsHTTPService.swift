//
//  MovieDetailsHTTPService.swift
//  PopMovies
//
//  Created by ecovali on 3/9/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MovieDetailsHTTPService {
    
    private let apiResquests: APIRequests
    private let coreDataService: MoviesCoreDataService
    
    init(apiResquests: APIRequests, coreDataService: MoviesCoreDataService) {
        self.apiResquests = apiResquests
        self.coreDataService = coreDataService
    }
    
    func getVideosByMovie(id: Int) -> Single<[Video]> {
        return apiResquests.videos(movieId: id)
            .map { response -> [Video] in
                return response.videos
            }
            .flatMap { [weak self] videos in
                (self?.coreDataService.addMovie(videos: videos, with: id) ?? .just(()))
                .map { videos }
            }
    }
}
