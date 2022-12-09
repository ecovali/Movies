//
//  Video.swift
//  PopMovies
//
//  Created by ecovali on 3/9/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxDataSources

public struct Video: Codable {
    
    let id: String
    let iso6391: String
    let iso31661: String
    let key: String
    let name: String
    let site: String
    let size: Int
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case iso6391 = "iso_639_1"
        case iso31661 = "iso_3166_1"
        case key
        case name
        case site
        case size
        case type
    }
    
    init(videoCD: VideoCD) {
        self.id = videoCD.id
        self.iso6391 = videoCD.iso6391
        self.iso31661 = videoCD.iso31661
        self.key = videoCD.key
        self.name = videoCD.name
        self.site = videoCD.site
        self.size = Int(videoCD.size)
        self.type = videoCD.type
    }
    
    // MARK: - Protocol Conformance
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? String()
        iso6391 = try container.decodeIfPresent(String.self, forKey: .iso6391) ?? String()
        iso31661 = try container.decodeIfPresent(String.self, forKey: .iso31661) ?? String()
        key = try container.decodeIfPresent(String.self, forKey: .key) ?? String()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? String()
        site = try container.decodeIfPresent(String.self, forKey: .site) ?? String()
        size = try container.decodeIfPresent(Int.self, forKey: .size) ?? Int()
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? String()
        
    }
}

extension Video: IdentifiableType {
    public var identity: String {
        return id
    }
}

extension Video: Equatable {
    public static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.id == rhs.id
    }
}
