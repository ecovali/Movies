//
//  BaseCoordinator.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import RxSwift

class BaseCoordinator: NSObject {
    
    var childCoordinators = [BaseCoordinator]()
    
    internal let router: RouterProtocol
    internal let disposeBag = DisposeBag()
    
    init(router: RouterProtocol) {
        self.router = router
    }
    
    func start() {
        fatalError("Please override 'start' method in child coordinator")
    }
    
    func addDependency(_ coordinator: BaseCoordinator) {
        guard childCoordinators.first(where: { [weak coordinator] in $0 === coordinator }) == nil else { return }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: BaseCoordinator?) {
        guard !childCoordinators.isEmpty, let coordinator = coordinator else { return }
        if let index = childCoordinators.firstIndex(where: { [weak coordinator] in $0 === coordinator }) {
            childCoordinators.remove(at: index)
            print(childCoordinators)
        }
    }
}
