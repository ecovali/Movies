//
//  APIClientResponse+Additions.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation

extension APIClientResponse {
    var movies: [Movie] {
        guard let data = try? json?.rawData(), let movies = try? JSONDecoder().decode([Movie].self, from: data) else {
                return []
        }
        return movies
    }
    
    var videos: [Video] {
        guard let data = try? json?.rawData(), let videos = try? JSONDecoder().decode([Video].self, from: data) else {
                return []
        }
        return videos
    }
}
