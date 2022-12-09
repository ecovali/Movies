//
//  PopMoviesCollectionViewController.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import Device

class PopMoviesCollectionViewController: UIViewController {
    
    struct Constants {
        static var ratio = CGFloat(0.67123)
        static var popMovies = "Pop Movies"
    }
    
    @IBOutlet weak var collectionView: CollectionView!
    private var portraitCellWidth = CGFloat()
    private var landscapeCellWidth = CGFloat()
    
    lazy var portraitLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.popMoviesStyleFor(portraitCellWidth)
        return layout
    }()
    
    lazy var landscapeLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.popMoviesStyleFor(landscapeCellWidth)
        return layout
    }()
    
    private let disposeBag = DisposeBag()
    var viewModel: PopMoviesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setup()
        title = Constants.popMovies
    }
    
    private func setup() {
        setupCollectionViewLayout()
    }
    
    private func setupCollectionViewLayout() {
        let size = UIScreen.main.bounds.size
        let isLandscape = size.width > size.height
        setupPortraitLandscapeCellWidths(isLandscape)
        let layout = isLandscape ? landscapeLayout : portraitLayout
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.reloadData()
    }
    
    private func bind() {
        
        rx.viewWillAppear.map { _ in () }
            .take(1)
            .bind(to: viewModel.attach)
            .disposed(by: disposeBag)
        
        rx.viewDidLayoutSubviews
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.hasLoadMore.onNext(true)
            })
            .disposed(by: disposeBag)
        
        let config = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .fade)
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource
            <AnimatableSectionModel<Int, Movie>>(animationConfiguration: config,
                                                 decideViewTransition: { _, _, changesSet in
                                                    return changesSet.isEmpty ? .reload : .animated
            }, configureCell: { _, collectionView, index, movie in
                
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopMovieCollectionViewCell.identifier, for: index) as? PopMovieCollectionViewCell {
                    cell.setup(movie: movie)
                    return cell
                }
                
                return UICollectionViewCell()
            })
        
        viewModel.displayMovies
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel
            .orientation
            .subscribe(onNext: { [weak self] orientation in
                self?.setupCollectionViewLayout()
                self?.applyNew(orientation)
            })
            .disposed(by: disposeBag)
        
        collectionView.reload
            .bind(to: viewModel.relaod)
            .disposed(by: disposeBag)
        
        collectionView.loadMore.bind(to: viewModel.loadMore)
            .disposed(by: disposeBag)
        
        viewModel.loading
            .observeOn(MainScheduler.asyncInstance)
            .ignoreNil()
            .subscribe(onNext: { [weak self] value in
                self?.applyNew(value)
            })
            .disposed(by: disposeBag)
        
        viewModel.alerts
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { viewData in
                AppStylePopup.show(viewData: viewData)
            })
            .disposed(by: disposeBag)
        
        viewModel.error
        .observeOn(MainScheduler.asyncInstance)
        .subscribe(onNext: { [weak self] viewData in
            if let viewData = viewData {
                InformalView.showInView(self?.collectionView, with: viewData)
            } else {
                InformalView.hideFromView(self?.collectionView)
            }
        })
        .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Movie.self)
            .bind(to: viewModel.didSelect)
            .disposed(by: disposeBag)
    }
    
    private func applyNew(_ value: (type: LoadingType, state: Bool)) {
        
        switch (value.type, value.state) {
        case (.loading, true):
            LoadingView.showInView(self.view, style: .fullWithSmallWhiteBg)
        case (.loading, false):
            LoadingView.hideLoaderFrom(self.view)
        case (.reloading, false):
            collectionView.endRefreshing()
        case (.loadMore, false):
            collectionView.endLoadMore()
        default: break
        }
    }
    
    private func applyNew(_ orientation: UIDeviceOrientation) {
        if !(orientation == .faceUp || orientation == .faceDown) {
            let layout = orientation.isLandscape ? landscapeLayout : portraitLayout
            collectionView.setCollectionViewLayout(layout, animated: true)
            collectionView.reloadData()
        }
    }
    
    private func setupPortraitLandscapeCellWidths(_ isLandscape: Bool) {
        if portraitCellWidth == 0 && landscapeCellWidth == 0 {
            let scaleMode: CGFloat = Device.isPadScreen ? 2 : 1
            if isLandscape {
                landscapeCellWidth = collectionView.frame.size.width / scaleMode / 3
                portraitCellWidth = collectionView.frame.size.height / scaleMode / 2
            } else {
                landscapeCellWidth = collectionView.frame.size.height / scaleMode / 3
                portraitCellWidth = collectionView.frame.size.width / scaleMode / 2
            }
        }
    }
}

private extension UICollectionViewFlowLayout {
    
    func popMoviesStyleFor( _ cellWidth: CGFloat) {
        scrollDirection = .vertical
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        
        itemSize = CGSize(width: cellWidth, height: cellWidth / PopMoviesCollectionViewController.Constants.ratio)
    }
    
}
