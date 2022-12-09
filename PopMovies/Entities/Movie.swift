//
//  Movie.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxDataSources

public struct Movie: Codable {
    
    let popularity: Float
    let voteCount: Int
    let video: Bool
    let posterPath: String
    let id: Int
    let adult: Bool
    let backdropPath: String
    let originalLanguage: String
    let originalTitle: String
    let genreIds: [Int]
    let title: String
    let overview: String
    let voteAverage: Float
    let releaseDate: Date

    enum CodingKeys: String, CodingKey {
        case popularity
        case voteCount = "vote_count"
        case video
        case posterPath = "poster_path"
        case id
        case adult
        case backdropPath = "backdrop_path"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case genreIds = "genre_ids"
        case title
        case overview
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }

    init(movieCD: MovieCD) {
        
        self.popularity = movieCD.popularity
        self.voteCount = Int(movieCD.voteCount)
        self.video = movieCD.video
        self.posterPath = movieCD.posterPath ?? String()
        self.id = Int(movieCD.id)
        self.adult = movieCD.adult
        self.backdropPath = movieCD.backdropPath ?? String()
        self.originalLanguage = movieCD.originalLanguage ?? String()
        self.originalTitle = movieCD.originalTitle ?? String()
        self.genreIds = (movieCD.genreIds ?? []).map { Int($0) }
        self.title = movieCD.title ?? String()
        self.overview = movieCD.overview ?? String()
        self.voteAverage = movieCD.voteAverage
        self.releaseDate = movieCD.releaseDate ?? Date()
    }
    
    // MARK: - Protocol Conformance
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        popularity = try container.decodeIfPresent(Float.self, forKey: .popularity) ?? Float()
        voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount) ?? Int()
        video = try container.decodeIfPresent(Bool.self, forKey: .video) ?? false
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath) ?? String()
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? Int()
        adult = try container.decodeIfPresent(Bool.self, forKey: .adult) ?? false
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath) ?? String()
        originalLanguage = try container.decodeIfPresent(String.self, forKey: .originalLanguage) ?? String()
        originalTitle = try container.decodeIfPresent(String.self, forKey: .originalTitle) ?? String()
        genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIds) ?? []
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? String()
        overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? String()
        voteAverage = try container.decodeIfPresent(Float.self, forKey: .voteAverage) ?? Float()
        
        if let releaseDateDateValue = try container.decodeIfPresent(String.self, forKey: .releaseDate) {
            releaseDate = Constants.DateFormats.movie.date(from: releaseDateDateValue) ?? Date()
        } else { releaseDate = Date() }
    }
}

extension Movie: IdentifiableType {
    public var identity: Int {
        return id
    }
}

extension Movie: Equatable {
    public static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}
