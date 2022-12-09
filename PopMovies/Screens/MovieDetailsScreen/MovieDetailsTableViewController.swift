//
//  MovieDetailsTableViewController.swift
//  PopMovies
//
//  Created by ecovali on 3/9/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class MovieDetailsTableViewController: UITableViewController {
    
    struct UIConstants {
        struct Color {
            static let releaseDate = UIColor.white
            static let raiting = UIColor.white
        }
        struct FontSize {
            static let releaseDate: CGFloat = 20.0
            static let raiting: CGFloat = 16.0
        }
        struct Font {
            static let releaseDate = UIFont.boldSystemFont(ofSize: FontSize.releaseDate)
            static let raiting = UIFont.systemFont(ofSize: FontSize.raiting)
        }
        struct Attributes {
            static let raiting = [NSAttributedString.Key.foregroundColor: Color.raiting,
                                  NSAttributedString.Key.font: Font.raiting]
            static let releaseDate = [NSAttributedString.Key.foregroundColor: Color.releaseDate,
                                      NSAttributedString.Key.font: Font.releaseDate]}
    }

    @IBOutlet weak var backdropImageView: PosterImageView!
    @IBOutlet weak var posterImageView: PosterImageView!
    @IBOutlet weak var nameMovieLabel: UILabel!
    @IBOutlet weak var shortDetailsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var videosTableView: TableView!
    
    private let disposeBag = DisposeBag()
    var viewModel: MovieDetailsViewModel!
    
    struct MovieDetailsIndexPaths {
        static let description = IndexPath(row: 0, section: 0)
        static let separator = IndexPath(row: 1, section: 0)
        static let videos = IndexPath(row: 2, section: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    private func setup() {
        backdropImageView.type.onNext(.backdrop)
    }
    
    private func bind() {
        
        rx.viewWillAppear.map { _ in () }
        .take(1)
        .bind(to: viewModel.attach)
        .disposed(by: disposeBag)
        
        let config = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .fade)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource
            <AnimatableSectionModel<Int, Video>>(animationConfiguration: config,
                                                 decideViewTransition: { _, _, changesSet in
                                                    return changesSet.isEmpty ? .reload : .animated
            }, configureCell: { _, tableView, index, video in
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: VideoTableViewCell.identifier, for: index) as? VideoTableViewCell {
                    cell.setup(video: video)
                    return cell
                }
                
                return UITableViewCell()
            })
        
        viewModel.displayVideos
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: videosTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.displayVideos
                    .observeOn(MainScheduler.asyncInstance)
                    .subscribe(onNext: { [weak self] _ in
                        self?.tableView.reloadData()
                    })
                    .disposed(by: disposeBag)
        
        viewModel.movie
            .ignoreNil()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] movie in
                self?.fillBy(movie)
            })
            .disposed(by: disposeBag)
        
        videosTableView.rx.modelSelected(Video.self)
            .bind(to: viewModel.didSelect)
            .disposed(by: disposeBag)
        
        viewModel.attach
            .bind(to: videosTableView.appear)
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
                InformalView.showInView(self?.navigationController?.view, with: viewData)
            } else {
                InformalView.hideFromView(self?.navigationController?.view)
            }
        })
        .disposed(by: disposeBag)
        
        Observable.zip(
            rx.viewDidDisappear, rx.willMoveToParentViewController, resultSelector: { _, _ in })
            .observeOn(MainScheduler.instance)
            .bind(to: viewModel.finish)
            .disposed(by: disposeBag)
    }
    
    private func fillBy(_ movie: Movie) {
        posterImageView.movie.onNext(movie)
        backdropImageView.movie.onNext(movie)
        nameMovieLabel.text = movie.title
        descriptionLabel.text = movie.overview
        shortDetailsLabel.attributedText = movie.rightDescription
        tableView.reloadData()
    }
    
    private func applyNew(_ value: (type: LoadingType, state: Bool)) {
        
        guard let view = self.navigationController?.view else { return }
        
        switch (value.type, value.state) {
        case (.loading, true), (.reloading, true):
            LoadingView.showInView(view, style: .fullWithSmallWhiteBg)
        case (.loading, false):
            LoadingView.hideLoaderFrom(view)
        case (.reloading, false):
            LoadingView.hideLoaderFrom(view)
            videosTableView.endRefreshing()
        case (.loadMore, false):
            videosTableView.endLoadMore()
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if MovieDetailsIndexPaths.videos == indexPath {
            return videosTableView.rowHeight * CGFloat(viewModel.countOfVideos)
        } else if MovieDetailsIndexPaths.separator == indexPath {
            if 0 == viewModel.countOfVideos {
                return .leastNormalMagnitude
            }
        }
        return UITableView.automaticDimension
    }
}

private extension Movie {
    
    var rightDescription: NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(releaseDateAttributedString)
        result.append(NSAttributedString(string: "\n"))
        result.append(raitingAttributedString)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.lineBreakMode = .byTruncatingTail
        
        result.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: result.length))
        
        return result
    }
    
    var releaseDateAttributedString: NSAttributedString {
        let value = Constants.DateFormats.year.string(from: releaseDate)
        return NSMutableAttributedString(string: value, attributes: MovieDetailsTableViewController.UIConstants.Attributes.releaseDate)
    }
    
    var raitingAttributedString: NSAttributedString {
        return NSMutableAttributedString(string: "\(voteAverage)/10", attributes: MovieDetailsTableViewController.UIConstants.Attributes.raiting)
    }
    
}
