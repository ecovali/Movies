//
//  MoviesCoreDataService.swift
//  PopMovies
//
//  Created by ecovali on 3/6/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

enum MoviesCoreDataServiceError: String, Error, LocalizedError {
    
    case movieNotFound = "Could not find Movie"
    case movieAlreadyExists = "Movie already exists"
    
    var errorDescription: String? {
        return rawValue
    }
}

class MoviesCoreDataService {
    
    private let coreDataService: CoreDataService
    
    lazy var backgroundContext = {
        return coreDataService.newBackgroundContext()
    }()
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }
    
    public func fetchMoviesFor(_ page: Int) -> Single<[Movie]> {
        return Single.create(subscribe: { single in
            
            self.backgroundContext.performAndWait {
                let pageFetchRequest: NSFetchRequest<Page> = Page.fetchRequest(predicate: NSPredicate(format: "number == %d", page))
                
                do {
                    let pages = try self.backgroundContext.fetch(pageFetchRequest)
                    let moviesArray = Array(pages.first?.movies ?? NSSet()) as? [MovieCD] ?? []
                    let movies = moviesArray
                        .sorted(by: { $0.index < $1.index })
                        .compactMap { value -> Movie? in
                            return Movie(movieCD: value)
                        }

                    single(.success(movies))
                } catch {
                    single(.error(error))
                }
            }
            
            return Disposables.create {
                self.backgroundContext.reset()
            }
        })
    }
    
    public func fetchMovie(with id: Int) -> Single<Movie> {
        return Single.create(subscribe: { single in
            self.backgroundContext.performAndWait {
                let request: NSFetchRequest<MovieCD> = MovieCD.fetchRequest(predicate: NSPredicate(format: "id == %d", id))
                request.fetchLimit = 1
                
                do {
                    if let movie = try self.backgroundContext.fetch(request).first {
                        single(.success(Movie(movieCD: movie)))
                    } else {
                        single(.error(MoviesCoreDataServiceError.movieNotFound))
                    }
                } catch {
                    single(.error(error))
                }
            }
            
            return Disposables.create {
                self.backgroundContext.reset()
            }
        })
    }
    
    public func fetchVideos(for movieId: Int) -> Single<[Video]> {
        return Single.create(subscribe: { single in
            self.backgroundContext.performAndWait {
                let request: NSFetchRequest<VideoCD> = VideoCD.fetchRequest(predicate: NSPredicate(format: "movie.id == %d", movieId))
                
                do {
                    let videosCD = try self.backgroundContext.fetch(request)
                    let videos = videosCD.map { Video(videoCD: $0) }
                    single(.success(videos))
                } catch {
                    single(.error(error))
                }
            }
            
            return Disposables.create {
                self.backgroundContext.reset()
            }
        })
    }
    
    public func addMoviesPage(_ movies: [Movie], page: Int) -> Single<Void> {
        return Single.create(subscribe: { single in
            
            let cdMovies = movies.enumerated().map { value -> MovieCD in
                let newMovie = MovieCD(context: self.backgroundContext)
                newMovie.setup(movie: value.element, index: Int64(value.offset))
                return newMovie
            }
            
            let newPage = Page(context: self.backgroundContext)
            newPage.number = Int64(page)
            newPage.movies = NSSet(array: cdMovies)
            
            do {
                try self.backgroundContext.save()
                single(.success(()))
            } catch {
                single(.error(error))
            }
            
            return Disposables.create()
        })
    }
    
    public func removeAllPages() -> Single<Void> {
        return Single.create(subscribe: { single in
            self.backgroundContext.performAndWait {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Page")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try self.backgroundContext.execute(deleteRequest)
                    try self.backgroundContext.save()
                    single(.success(()))
                } catch {
                    single(.error(error))
                }
            }

            return Disposables.create()
        })
    }
    
    public func addMovie(videos: [Video], with id: Int) -> Single<Void> {
        return Single.create(subscribe: { single in
            self.backgroundContext.performAndWait {
                let request: NSFetchRequest<MovieCD> = MovieCD.fetchRequest(predicate: NSPredicate(format: "id == %d", id))
                request.fetchLimit = 1
                
                do {
                    if let movie = try self.backgroundContext.fetch(request).first {
                        
                        videos.forEach { value in
                            let newVideo = VideoCD(context: self.backgroundContext)
                            newVideo.setup(video: value)
                            movie.addToVideos(newVideo)
                        }
                        
                        try self.backgroundContext.save()
                        
                        single(.success(()))
                    } else {
                        single(.error(MoviesCoreDataServiceError.movieNotFound))
                    }
                } catch {
                    single(.error(error))
                }
            }
            
            return Disposables.create()
        })
    }
}
