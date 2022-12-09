//
//  APIEndpoints.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Alamofire

struct Endpoint {
    
    enum Method: String {
        case get      = "GET"
        case post     = "POST"
        case put      = "PUT"
        case patch    = "PATCH"
        case delete   = "DELETE"
        case upload   = "UPLOAD"
        case download = "DOWNLOAD"
        var alamofireMethod: HTTPMethod {
            switch self {
            case .get, .post, .put, .patch, .delete:
                return HTTPMethod(rawValue: self.rawValue) ?? .get
            case .upload:
                return .post
            case .download:
                return .get
            }
        }
    }
    var path: String
    let method: Method
    
    let host: String?
    var params: [String: Any]?
    var headers: [String: String]?
    
    var fullPath: String {
        return (host ?? Constants.URLs.BaseURL.development) + path
    }
    init(path: String, method: Method = .get, host: String? = nil) {
        self.path = path
        self.method = method
        self.host = host
    }
    
    static var moviePopular: Endpoint {
        return Endpoint(path: Constants.URLs.moviePopular, method: .get)
    }
    
}
