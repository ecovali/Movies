//
//  RechabilityService.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import Reachability
import RxSwift
import RxCocoa

protocol ReachabilityProtocol: class {
    var connection: Reachability.Connection { get }
    
    func startNotifier() throws
    func stopNotifier()
}

class ReachabilityService {
    
    static var shared = ReachabilityService()
    
    let onReachabilityRestore = PublishSubject<()>()
    var reachable = BehaviorSubject(value: true)
    var isReachable: Bool {
        switch reachability?.connection ?? .unavailable {
        case .none, .unavailable:
            return false
        default:
            return true
        }
    }
    
    private var reachability: ReachabilityProtocol!
    private let disposeBag = DisposeBag()
    
    static func setSharedRechabilityObject(_ rechability: ReachabilityProtocol?) {
        shared.reachability = rechability
    }
    
    private init() {
        let notification = NotificationCenter.default.rx
            .notification(Notification.Name.reachabilityChanged)
            .map({ _ in self.isReachable })
        
        reachable
            .skip(2)
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in () }
            .bind(to: onReachabilityRestore)
            .disposed(by: disposeBag)
        
        notification
            .bind(to: reachable)
            .disposed(by: disposeBag)
    }
    
    func startNotifier() {
        try? reachability?.startNotifier()
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
    }
}

extension Reachability: ReachabilityProtocol {}
