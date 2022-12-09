//
//  ApplicationCoordinator.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxSwift

final class ApplicationCoordinator: BaseCoordinator {
    
    override func start() {
        guard let coordinator = DIManager.shared.resolve(PopMoviesCoordinator.self) else { return }
        addDependency(coordinator)
        coordinator.start()
    }
}
