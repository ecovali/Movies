//
//  VideoCD.swift
//  PopMovies
//
//  Created by ecovali on 3/9/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import CoreData

@objc(VideoCD)
public class VideoCD: NSManagedObject {
    
    @nonobjc public class func fetchRequest(predicate: NSPredicate? = nil) -> NSFetchRequest<VideoCD> {
        let request = NSFetchRequest<VideoCD>(entityName: "VideoCD")
        request.predicate = predicate
        return request
    }

    @NSManaged public var id: String
    @NSManaged public var iso6391: String
    @NSManaged public var iso31661: String
    @NSManaged public var key: String
    @NSManaged public var name: String
    @NSManaged public var site: String
    @NSManaged public var size: Int64
    @NSManaged public var type: String
    
    func setup(video: Video) {
        self.id = video.id
        self.iso6391 = video.iso6391
        self.iso31661 = video.iso31661
        self.key = video.key
        self.name = video.name
        self.site = video.site
        self.size = Int64(video.size)
        self.type = video.type
    }
}
