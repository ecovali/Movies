//
//  APIClientProtocols.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import Alamofire

private struct UIConstats {
    static let mimeType = "image/jpeg"
    static let comment = "comment"
}

typealias UploadModelType = (part1: ( data: Data, name: String, fileName: String, url: URLConvertible, method: HTTPMethod, parameters: Parameters?),
                             part2: (queue: DispatchQueue?, headers: HTTPHeaders?, comment: String))

extension DataRequest: DataRequestProtocol {
    func responsee(queue: DispatchQueue?, completionHandler: @escaping (DefaultDataResponse) -> Void) -> DataRequestProtocol {
        return self.response(queue: queue, completionHandler: completionHandler)
    }
    
    func validatee() -> DataRequestProtocol {
        return self.validate()
    }
}

extension Alamofire.SessionManager: AlamofireSessionProtocol {
    var adapterAndRetier: RequestAdapter? {
        get {
            return retrier as? RequestAdapter
        }
        set {
            adapter = newValue
        }
    }

    func request(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders?) -> DataRequestProtocol {
        let useJSONEncoding = method == .post || method == .patch || method == .put
        if useJSONEncoding {
            return self.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        }
        return self.request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers)
    }
    
    func upload(value: UploadModelType) -> Observable<DefaultDataResponse> {

        return Observable.create { [weak self] observable in
            self?.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(value.part1.data, withName: value.part1.name, fileName: value.part1.fileName, mimeType: UIConstats.mimeType)
                if !value.part2.comment.isEmpty {
                    if let data = value.part2.comment.data(using: .utf8) {
                        multipartFormData.append(data, withName: UIConstats.comment)
                    }
                }
            }, usingThreshold: UInt64(),
               to: value.part1.url,
               method: value.part1.method,
               headers: value.part2.headers,
               queue: value.part2.queue,
               encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                      upload.response { response in
                        observable.onNext(response)
                      }
                case .failure(let encodingError):
                     observable.onError(encodingError)
                }
            })
            return Disposables.create()
        }
    }
}

protocol DataRequestProtocol {
    func responsee(queue: DispatchQueue?, completionHandler: @escaping (DefaultDataResponse) -> Void) -> DataRequestProtocol
    func validatee() -> DataRequestProtocol
    func cancel()
}

protocol AlamofireSessionProtocol {
    var adapterAndRetier: RequestAdapter? { get set }
    
    func request(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders?) -> DataRequestProtocol
    func upload(value: UploadModelType) -> Observable<DefaultDataResponse>
}

protocol APIClientProtocol {
    func perform(endpoint: Endpoint) -> Single<APIClientResponse>
}

protocol AuthServiceProtocol {
    var isAuthorized: Bool { get }
    
    func saveAuthResponse(_ response: JSON)
}

protocol AppDelegateLogOutProtocol {
    func logout()
}
