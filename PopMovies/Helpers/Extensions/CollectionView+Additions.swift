//
//  CollectionView+Additions.swift
//  PopMovies
//
//  Created by ecovali on 3/6/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class CollectionView: UICollectionView {
    
    // Input
    let hasLoadMore = PublishSubject<Bool>()
    let appear = PublishSubject<Void>()
    
    // Output
    let reload = PublishSubject<Void>()
    let loadMore = PublishSubject<Void>()
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    private var localRefreshControll: UIRefreshControl!
    private let disposeBag = DisposeBag()
    private var loadMoreActivityIndicatorView: UIView?
    private var refreshLoadingView: UIView!
    private var isLoadMoreCalled = false {
        didSet {
            if oldValue != isLoadMoreCalled && isLoadMoreCalled {
                loadMore.onNext(())
            }
        }
    }
    private var isLowerThanResetingPoint = false
    
    var isRefreshing: Bool {
        return localRefreshControll?.isRefreshing ?? false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupRefreshControll()
        bind()
    }
    
    private func bind() {
        rx.observeWeakly(CGPoint.self, "contentOffset")
            .withLatestFrom(hasLoadMore)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] hasLoadMore in
                self?.handleScroll(hasLoadMore)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleScroll(_ isLoadMoreEnable: Bool) {
        let pullDistance = max(0.0, -self.localRefreshControll.frame.origin.y)
        let pullRatio = min( max(pullDistance, 0.0), 100.0) / 100.0
        refreshLoadingView.alpha = localRefreshControll.isRefreshing ? 1 : pullRatio
        refreshLoadingView.height = localRefreshControll.height + 10
        
        guard loadMore.hasObservers && isLoadMoreEnable else { return }
        
        if contentSize.height > height {
            if !isLoadMoreCalled {
                let offset = contentSize.height - height
                isLoadMoreCalled = contentOffset.y >= offset
                if isLoadMoreCalled {
                    setupLoadMoreIndicator()
                }
            } else if isLowerThanResetingPoint && contentOffset.y <= (contentSize.height - height * 1.8) {
                isLoadMoreCalled = false
            }
        }
        isLowerThanResetingPoint = contentOffset.y > (contentSize.height - height * 1.8)
    }
    
    private func setupRefreshControll() {
        localRefreshControll = UIRefreshControl()
        refreshLoadingView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: localRefreshControll.height))
        refreshLoadingView.alpha = 0
        refreshLoadingView.backgroundColor = UIColor.clear
        refreshLoadingView.clipsToBounds = true
        LoadingView.showInView(refreshLoadingView, style: .fullWithClearBg)
        localRefreshControll.tintColor = UIColor.clear
        localRefreshControll.insertSubview(refreshLoadingView, at: 0)
        
        guard let event = localRefreshControll?.rx.controlEvent(.valueChanged) else { return }
        
        Observable.zip(event, rx.didEndDecelerating, resultSelector: { _, _ in () })
            .do(onNext: { [weak self] _ in
                self?.feedbackGenerator.notificationOccurred(.success)
            })
            .bind(to: reload)
            .disposed(by: disposeBag)
        
        insertSubview(localRefreshControll, at: 0)
        
        appear
            .subscribe(onNext: { [weak self] _ in
                guard self?.localRefreshControll?.isRefreshing ?? false else { return }
                self?.contentOffset = CGPoint(x: 0, y: -(self?.localRefreshControll?.bounds.size.height ?? 1))
                self?.localRefreshControll.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupLoadMoreIndicator() {
        guard loadMoreActivityIndicatorView == nil else { return }
        loadMoreActivityIndicatorView = UIView(frame: CGRect(x: 0, y: contentSize.height - 100,
                                                             width: width, height: 100))
        loadMoreActivityIndicatorView?.backgroundColor = UIColor.clear
        if let view = loadMoreActivityIndicatorView {
            LoadingView.showInView(view, style: .fullWithClearBg)
        }
    }
    
    func endRefreshing() {
        if !isDragging {
            localRefreshControll?.endRefreshing()
        } else {
            rx.didEndDragging
                .take(1)
                .timeout(10, scheduler: MainScheduler.asyncInstance)
                .catchErrorJustReturn(true)
                .filter { $0 }
                .subscribe(onNext: { [weak self] _ in
                    self?.localRefreshControll?.endRefreshing()
                })
                .disposed(by: disposeBag)
        }
    }
    
    func endLoadMore() {
        let yContentOffset = contentOffset.y
        LoadingView.hideLoaderFrom(loadMoreActivityIndicatorView)
        loadMoreActivityIndicatorView?.removeFromSuperview()
        contentOffset.y = yContentOffset
        killScroll()
    }
}

class TableView: UITableView {
    
    // Input
    let hasLoadMore = PublishSubject<Bool>()
    let appear = PublishSubject<Void>()
    
    // Output
    let reload = PublishSubject<Void>()
    let loadMore = PublishSubject<Void>()
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    private var localRefreshControll: UIRefreshControl!
    private let disposeBag = DisposeBag()
    private var loadMoreActivityIndicatorView: UIView?
    private var refreshLoadingView: UIView!
    private var isLoadMoreCalled = false {
        didSet {
            if oldValue != isLoadMoreCalled && isLoadMoreCalled {
                loadMore.onNext(())
            }
        }
    }
    private var isLowerThanResetingPoint = false
    
    var isRefreshing: Bool {
        return localRefreshControll?.isRefreshing ?? false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupRefreshControll()
        bind()
    }
    
    private func bind() {
        rx.observeWeakly(CGPoint.self, "contentOffset")
            .withLatestFrom(hasLoadMore)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] hasLoadMore in
                self?.handleScroll(hasLoadMore)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleScroll(_ isLoadMoreEnable: Bool) {
        let pullDistance = max(0.0, -self.localRefreshControll.frame.origin.y)
        let pullRatio = min( max(pullDistance, 0.0), 100.0) / 100.0
        refreshLoadingView.alpha = localRefreshControll.isRefreshing ? 1 : pullRatio
        refreshLoadingView.height = localRefreshControll.height + 10
        
        guard loadMore.hasObservers && isLoadMoreEnable else { return }
        
        if contentSize.height > height {
            if !isLoadMoreCalled {
                let offset = contentSize.height - height
                isLoadMoreCalled = contentOffset.y >= offset
                if isLoadMoreCalled {
                    setupLoadMoreIndicator()
                }
            } else if isLowerThanResetingPoint && contentOffset.y <= (contentSize.height - height * 1.8) {
                isLoadMoreCalled = false
            }
        }
        isLowerThanResetingPoint = contentOffset.y > (contentSize.height - height * 1.8)
    }
    
    private func setupRefreshControll() {
        localRefreshControll = UIRefreshControl()
        refreshLoadingView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: localRefreshControll.height))
        refreshLoadingView.alpha = 0
        refreshLoadingView.backgroundColor = UIColor.clear
        refreshLoadingView.clipsToBounds = true
        LoadingView.showInView(refreshLoadingView, style: .fullWithClearBg)
        localRefreshControll.tintColor = UIColor.clear
        localRefreshControll.insertSubview(refreshLoadingView, at: 0)
        
        guard let event = localRefreshControll?.rx.controlEvent(.valueChanged) else { return }
        
        Observable.zip(event, rx.didEndDecelerating, resultSelector: { _, _ in () })
            .do(onNext: { [weak self] _ in
                self?.feedbackGenerator.notificationOccurred(.success)
            })
            .bind(to: reload)
            .disposed(by: disposeBag)
        
        insertSubview(localRefreshControll, at: 0)
        
        appear
            .subscribe(onNext: { [weak self] _ in
                guard self?.localRefreshControll?.isRefreshing ?? false else { return }
                self?.contentOffset = CGPoint(x: 0, y: -(self?.localRefreshControll?.bounds.size.height ?? 1))
                self?.localRefreshControll.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupLoadMoreIndicator() {
        guard loadMoreActivityIndicatorView == nil else { return }
        loadMoreActivityIndicatorView = UIView(frame: CGRect(x: 0, y: contentSize.height,
                                                             width: width, height: 50))
        loadMoreActivityIndicatorView?.backgroundColor = UIColor.clear
        if let view = loadMoreActivityIndicatorView {
            LoadingView.showInView(view, style: .fullWithClearBg)
            tableFooterView = view
        }
    }
    
    func endRefreshing() {
        if !isDragging {
            localRefreshControll?.endRefreshing()
        } else {
            rx.didEndDragging
                .take(1)
                .timeout(10, scheduler: MainScheduler.asyncInstance)
                .catchErrorJustReturn(true)
                .filter { $0 }
                .subscribe(onNext: { [weak self] _ in
                    self?.localRefreshControll?.endRefreshing()
                })
                .disposed(by: disposeBag)
        }
    }
    
    func endLoadMore() {
        let yContentOffset = contentOffset.y
        LoadingView.hideLoaderFrom(loadMoreActivityIndicatorView)
        loadMoreActivityIndicatorView?.removeFromSuperview()
        tableFooterView = nil
        contentOffset.y = yContentOffset
        killScroll()
    }
}

extension UIScrollView {
    
    func killScroll() {
        self.isScrollEnabled = false
        self.isScrollEnabled = true
    }
}

