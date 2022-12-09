//
//  Page+CoreDataClass.swift
//  PopMovies
//
//  Created by ecovali on 3/6/20.
//  Copyright © 2020 ecovali. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Page)
public class Page: NSManagedObject {
    
    @nonobjc public class func fetchRequest(predicate: NSPredicate? = nil) -> NSFetchRequest<Page> {
        let request = NSFetchRequest<Page>(entityName: "Page")
        request.predicate = predicate
        return request
    }

    @NSManaged public var number: Int64
    @NSManaged public var movies: NSSet?
    
    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: MovieCD)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: MovieCD)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: NSSet)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: NSSet)
}
