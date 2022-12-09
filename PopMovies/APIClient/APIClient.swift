//
//  APIClient.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON

class APIClient: APIClientProtocol {
    private struct ErrorMessages {
        static let opps = "Opps!"
        static let noConnection = "server_problem"
        static let couldNotSerializeErrorMessage = "Could not serialize error message."
        static let defautlError = "Something went wrong."
        static let notConfirmed = "NOT_CONFIRMED"
    }
    
    enum APIClientError: Error, LocalizedError {
        case notConfirmed
        case noConnection
        case serverError(String)
        case serializationError
        case unknownStatusCode(Int)
        case unauthorized
        case canceled
        case serverErrorMetadata([String: Any])
        
        var errorDescription: String? {
            switch self {
            case .notConfirmed:
                return ErrorMessages.notConfirmed
            case .noConnection:
                return ErrorMessages.noConnection
            case .serializationError:
                return "Could not serialize server resoponse"
            case .unknownStatusCode(let code):
                return "Unexpected status code: \(code)"
            case .unauthorized:
                return "Unauthorized request"
            case .canceled:
                return "Request was canceled"
            case .serverError(let error):
                return error
            case .serverErrorMetadata(let errorMetadata):
                return errorMetadata["message"] as? String
            }
        }
        
        var metaData: [String: Any]? {
            switch self {
            case .serverErrorMetadata(let errorMetadata):
                return errorMetadata
                
            default:
                return nil
            }
        }
    }
    
    private var sessionManager: AlamofireSessionProtocol
    private var clientQueue = DispatchQueue.global(qos: .userInitiated)
    
    init(sessionManager: AlamofireSessionProtocol) {
        self.sessionManager = sessionManager
    }
    
    func perform(endpoint: Endpoint) -> Single<APIClientResponse> {
        guard ReachabilityService.shared.isReachable else {
            return .error(APIClientError.noConnection)
        }
        
        let headers = endpoint.headers ?? [:]
        var finalParams = endpoint.params ?? [:]
        finalParams[Constants.apiKey] = Constants.apiKeyValue
        
        return Single.create(subscribe: { single in
            let request = self.sessionManager.request(endpoint.fullPath,
                                                      method: endpoint.method.alamofireMethod,
                                                      parameters: finalParams,
                                                      headers: headers)
            _ = request
                .validatee()
                .responsee(queue: self.clientQueue, completionHandler: { dataResponse in
                    let response = self.handleResponse(dataResponse)
                    single(response)
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    private func handleResponse(_ dataResponse: DefaultDataResponse) -> SingleEvent<APIClientResponse> {
        
        guard ReachabilityService.shared.isReachable else {
            return .error(APIClientError.noConnection)
        }
        
        guard let responseObject = dataResponse.response,
            let data = dataResponse.data else {
                if let error = dataResponse.error as? URLError,
                    URLError.Code.notConnectedToInternet == error.code {
                    return .error(APIClientError.noConnection)
                }
                return .error(APIClientError.canceled)
        }
        
        guard let jsonObject = try? JSON(data: data) else {
            
            if responseObject.statusCode == 204 {
                let data = APIClientResponse(data: Data(), json: nil)
                return .success(data)
            }
            
            let responseError = errorFrom(data: data)
            
            return .error(responseError)
        }
        
        switch responseObject.statusCode {
        case 200...300:
            let data = APIClientResponse(data: data, json: jsonObject["results"])
            return .success(data)
        case 400...500:
            let responseError = errorFrom(json: jsonObject)
            
            return .error(responseError)
        default:
            return .error(APIClientError.unknownStatusCode(responseObject.statusCode))
        }
    }
    
    private func errorFrom(data: Data) -> APIClientError {
        
        if let errorMessage = String(data: data, encoding: .utf8) {
            return .serverError(errorMessage)
        }
        
        return .serverError(ErrorMessages.couldNotSerializeErrorMessage)
    }
    
    private func errorFrom(json: JSON) -> APIClientError {
        
        if let errorMetaData = json["metadata"].dictionary {
            return .serverErrorMetadata(errorMetaData)
        }
        
        if let errorMessage = json["error"].string {
            return .serverError(errorMessage)
        }
        guard let error = json["error"].dictionary,
              let newMessage = error["message"]?.string,
              !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .serverError(ErrorMessages.couldNotSerializeErrorMessage)
        }
        return .serverError(newMessage)
    }
}
