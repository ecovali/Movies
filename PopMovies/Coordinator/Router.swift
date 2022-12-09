//
//  Router.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import UIKit

protocol RouterProtocol {
    var view: UIView? { get }
    func popToRoot(animated: Bool)
    var rootController: UINavigationController? { get set }
    func dismiss(animated: Bool, completion: (() -> ())?)
    func popTo(_ viewController: UIViewController, animated: Bool)
    func setRoot(_ viewController: UIViewController, hideBar: Bool)
    func setRoot(_ viewController: UIViewController, with animation: UIViewControllerAnimatedTransitioning, hideBar: Bool)
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> ())?)
    func pop(transition: UIViewControllerAnimatedTransitioning?, animated: Bool)
    func push(_ viewController: UIViewController, transition: UIViewControllerAnimatedTransitioning?, animated: Bool, completion: (() -> ())?)
    func popToViewControllerOfType(comparation: (UIViewController) -> Bool, animated: Bool) -> Bool
    func removeViewControllersFromHierarchy(comparation: (UIViewController) -> Bool)
    
    var hideNavigationBar: Bool { get set }
    var numbersOfControllers: Int { get }
}

final class Router: NSObject {
    
    weak var rootController: UINavigationController?
    
    private var completions = [UIViewController: () -> ()]()
    private var transition: UIViewControllerAnimatedTransitioning?
    
    var numbersOfControllers: Int {
        return rootController?.viewControllers.count ?? 0
    }
    
    init(rootController: UINavigationController) {
        self.rootController = rootController
        super.init()
        self.rootController?.delegate = self
    }
    
    private func runCompletion(for controller: UIViewController) {
        guard let completion = self.completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }
}

extension Router: RouterProtocol {
    
    var view: UIView? {
        return rootController?.view
    }
    
    var hideNavigationBar: Bool {
        get {
            return rootController?.isNavigationBarHidden ?? true
        }
        set {
            rootController?.isNavigationBarHidden = newValue
        }
    }
    
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
        rootController?.present(viewController, animated: animated, completion: {
            completion?()
        })
    }
    
    func push(_ viewController: UIViewController, transition: UIViewControllerAnimatedTransitioning? = nil, animated: Bool = true, completion: (() -> ())? = nil) {
        self.transition = transition
        if let completion = completion {
            self.completions[viewController] = completion
        }
        rootController?.pushViewController(viewController, animated: animated)
    }
    
    func pop(transition: UIViewControllerAnimatedTransitioning? = nil, animated: Bool = true) {
        self.transition = transition
        if let rootController = rootController?.viewControllers.last {
            completions.removeValue(forKey: rootController)
        }
        guard let controller = rootController?.popViewController(animated: animated) else { return }
        
        runCompletion(for: controller)
    }
    
    func popTo(_ viewController: UIViewController, animated: Bool = true) {
        rootController?.popToViewController(viewController, animated: animated)
    }
    
    func dismiss(animated: Bool = true, completion: (() -> ())?) {
        rootController?.dismiss(animated: animated, completion: completion)
    }
    
    func setRoot(_ viewController: UIViewController, hideBar: Bool = false) {
        viewController.tabBarItem = rootController?.tabBarItem
        rootController?.setViewControllers([viewController], animated: false)
        rootController?.isNavigationBarHidden = hideBar
    }
    
    func setRoot(_ viewController: UIViewController, with animation: UIViewControllerAnimatedTransitioning, hideBar: Bool) {
        rootController?.isNavigationBarHidden = hideBar
        push(viewController, transition: animation, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let last = self?.rootController?.viewControllers.last {
                self?.rootController?.viewControllers = [last]
            }
        }
    }
    
    func popToRoot(animated: Bool) {
        guard let controllers = self.rootController?.popToRootViewController(animated: animated) else { return }
        controllers.forEach { controller in
            self.runCompletion(for: controller)
        }
    }
    
    func popToViewControllerOfType(comparation: (UIViewController) -> Bool, animated: Bool) -> Bool {
        guard let vc = rootController?.viewControllers.first(where: { comparation($0) }) else { return false }
        popTo(vc, animated: animated)
        return true
    }
    
    func removeViewControllersFromHierarchy(comparation: (UIViewController) -> Bool) {
        let viewControllers = rootController?.viewControllers.filter { !comparation($0) }
        guard let newViewControllers = viewControllers else { return }
        rootController?.viewControllers = newViewControllers
    }
}

extension Router: UINavigationControllerDelegate {
    
    internal func navigationController(_ navigationController: UINavigationController,
                                       animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
}
