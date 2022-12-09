//
//  MovieCD.swift
//  PopMovies
//
//  Created by ecovali on 3/6/20.
//  Copyright © 2020 ecovali. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MovieCD)
public class MovieCD: NSManagedObject {

    @nonobjc public class func fetchRequest(predicate: NSPredicate? = nil) -> NSFetchRequest<MovieCD> {
        let request = NSFetchRequest<MovieCD>(entityName: "MovieCD")
        request.predicate = predicate
        return request
    }

    @NSManaged public var adult: Bool
    @NSManaged public var backdropPath: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var genreIds: [Int64]?
    @NSManaged public var id: Int64
    @NSManaged public var originalLanguage: String?
    @NSManaged public var originalTitle: String?
    @NSManaged public var popularity: Float
    @NSManaged public var releaseDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var video: Bool
    @NSManaged public var voteAverage: Float
    @NSManaged public var voteCount: Int64
    @NSManaged public var index: Int64
    @NSManaged public var overview: String?
    @NSManaged public var videos: NSSet?
    
    func setup(movie: Movie, index: Int64) {
        self.adult = movie.adult
        self.backdropPath = movie.backdropPath
        self.posterPath = movie.posterPath
        self.genreIds = movie.genreIds.map { Int64($0) }
        self.id = Int64(movie.id)
        self.originalLanguage = movie.originalLanguage
        self.originalTitle = movie.originalTitle
        self.popularity = movie.popularity
        self.releaseDate = movie.releaseDate
        self.title = movie.title
        self.overview = movie.overview
        self.video = movie.video
        self.voteCount = Int64(movie.voteCount)
        self.index = index
    }

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: VideoCD)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: MovieCD)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)
}
