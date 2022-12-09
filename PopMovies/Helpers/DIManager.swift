//
//  DIManager.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit
import Swinject
import SwinjectAutoregistration
import Alamofire
import Reachability
import RxSwift

class DIManager {
    
    static let shared = DIManager()
    
    var resolver: Resolver {
        return assembler.resolver
    }
    
    var assembler: Assembler
    let container: Container
    
    private init() {
        container = Container()
        let assambles: [Assembly] = [AppAssembly(),
                                     MoviesAssembly()]
        let assembler = Assembler(assambles, container: container)
        self.assembler = assembler
    }
    
    func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        return container.synchronize().resolve(serviceType)
    }
}

class AppAssembly: Assembly {
    
    func assemble(container: Container) {
        if let reachable = try? Reachability() {
            container.register(Reachability.self) { _ in reachable }
                .inObjectScope(.container)
        }
        
        container.register(ApplicationProtocol.self) { _ in
                    UIApplication.shared
        }
                .inObjectScope(.container)
        
        container.register(UINavigationController.self) { _ -> UINavigationController in
                    return AppDelegate.shared.rootController
        }
                 .inObjectScope(.container)
        
        container.autoregister(ApplicationCoordinator.self,
                               initializer: ApplicationCoordinator.init)
            .inObjectScope(.container)
        
        .inObjectScope(.container)
        container.register(APIRequests.self) { _ -> APIRequests in
            return APIRequests.shared
        }
        
        container.register(AlamofireSessionProtocol.self) { _ in return SessionManager.default }
            .inObjectScope(.container)
        
        container.autoregister(APIClient.self, initializer: APIClient.init)
            .inObjectScope(.container)
        
        container.autoregister(CoreDataService.self, initializer: CoreDataService.init)
        .inObjectScope(.container)
        
        container.autoregister(RouterProtocol.self,
                               initializer: Router.init)
            .inObjectScope(.container)
    }
    
    func loaded(resolver: Resolver) {
        APIRequests.shared.set(apiClient: resolver ~> APIClient.self)
        ReachabilityService.setSharedRechabilityObject(resolver ~> Reachability.self)
    }
}

class MoviesAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.autoregister(PopMoviesCoordinator.self,
                           initializer: PopMoviesCoordinator.init)
        .inObjectScope(.weak)
        
        container.autoregister(PopMoviesViewModel.self,
                           initializer: PopMoviesViewModel.init)
        .inObjectScope(.weak)
        
        container.autoregister(PopMoviesHTTPService.self,
                           initializer: PopMoviesHTTPService.init)
        .inObjectScope(.weak)
        
        container.autoregister(MovieDetailsViewModel.self,
                               argument: Movie.self,
                               initializer: MovieDetailsViewModel.init)
        .inObjectScope(.transient)
        
        container.autoregister(MovieDetailsHTTPService.self,
                           initializer: MovieDetailsHTTPService.init)
        .inObjectScope(.weak)
        
        container.autoregister(MoviesCoreDataService.self,
                           initializer: MoviesCoreDataService.init)
        .inObjectScope(.weak)
        
        }
}
