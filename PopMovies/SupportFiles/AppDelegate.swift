//
//  AppDelegate.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import AlamofireNetworkActivityLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    let disposeBag = DisposeBag()
    
    static let shared = UIApplication.shared.delegate as? AppDelegate ?? AppDelegate()

    var rootController: UINavigationController {
        return window?.rootViewController as? UINavigationController ?? UINavigationController()
    }
    
    var applicationCoordinator: ApplicationCoordinator? {
        return DIManager.shared.resolve(ApplicationCoordinator.self)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppearanceHelper.setupUIAppearance()
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        applicationCoordinator?.start()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
      ReachabilityService.shared.startNotifier()
    }
     
    func applicationDidEnterBackground(_ application: UIApplication) {
      ReachabilityService.shared.stopNotifier()
    }
     
    func applicationWillTerminate(_ application: UIApplication) {
      ReachabilityService.shared.stopNotifier()
    }
}
