//
//  APIRequests.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class APIRequests {
    
    private var apiClient: APIClientProtocol!
    
    static var shared = APIRequests()
    
     private init() {}
    
    func set(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func popularMovies(params: [String: Any]) -> Single<APIClientResponse> {
        var endpoint = Endpoint.moviePopular
        endpoint.params = params
        return apiClient.perform(endpoint: endpoint)
    }
    
    func videos(movieId: Int) -> Single<APIClientResponse> {
        let path = String(format: Constants.URLs.videos, "\(movieId)")
        return apiClient.perform(endpoint: Endpoint(path: path, method: .get))
    }
}
