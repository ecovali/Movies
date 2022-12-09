//
//  PopMoviesCoordinator.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Device

class PopMoviesCoordinator: BaseCoordinator {
    
    override func start() {
        if Device.isPadScreen {
            guard let popContainerScreen = popContainerViewController else { return }
            self.router.setRoot(popContainerScreen, hideBar: true)
        } else {
            guard let popMoviesScreen = popMoviesCollectionViewController else { return }
            self.router.setRoot(popMoviesScreen, hideBar: false)
        }
    }
    
    private var popContainerViewController: PopContainerViewController? {
        
        guard let popMovies = popMoviesCollectionViewController,
        let popContainerViewController = PopContainerViewController.initFromStoryboard(name: "PopMovies"),
        let placeholderViewController = UIViewController.initFromStoryboard(name: "PopMovies") else { return nil }
        
        let leftNaviagtionController = UINavigationController(navigationBarClass: MNavigationBar.self, toolbarClass: nil)
        leftNaviagtionController.setViewControllers([popMovies], animated: false)
        popContainerViewController.leftNaviagtionController = leftNaviagtionController
        popContainerViewController.addChild(leftNaviagtionController)
        
        let rightNaviagtionController = UINavigationController(navigationBarClass: MNavigationBar.self, toolbarClass: nil)
        rightNaviagtionController.setViewControllers([placeholderViewController], animated: false)
        popContainerViewController.rightNaviagtionController = rightNaviagtionController
        popContainerViewController.addChild(rightNaviagtionController)
        
        return popContainerViewController
    }
    
    private var popMoviesCollectionViewController: PopMoviesCollectionViewController? {
        
        guard let viewModel = DIManager.shared.container.synchronize()
               .resolve(PopMoviesViewModel.self) else { return nil }
        
        viewModel.showDetails
            .subscribe(onNext: { [weak self] movie in
                self?.openDetails(movie)
                })
            .disposed(by: disposeBag)
        
        let popMovies = PopMoviesCollectionViewController.initFromStoryboard(name: "PopMovies")
        popMovies?.viewModel = viewModel
        
        return popMovies
    }
     
    private func openDetails(_ movie: Movie) {
        if Device.isPadScreen {
            if let popContainerViewController = router.rootController?.viewControllers.first as? PopContainerViewController? {
                guard let details = movieDetailsTableViewController(movie) else { return }
                if let naviagtionController = popContainerViewController?.rightNaviagtionController {
                    naviagtionController.setViewControllers([details], animated: true)
                }
            }
        } else {
            guard let details = movieDetailsTableViewController(movie) else { return }
            router.push(details, transition: nil, animated: true, completion: nil)
        }
    }
    
    private func movieDetailsTableViewController(_ movie: Movie) -> MovieDetailsTableViewController? {
        
        guard let viewModel = DIManager.shared.container.synchronize()
               .resolve(MovieDetailsViewModel.self, argument: movie) else { return nil }
        
        let details = MovieDetailsTableViewController.initFromStoryboard(name: "MovieDetails")
        details?.viewModel = viewModel
        
        return details
    }
}
