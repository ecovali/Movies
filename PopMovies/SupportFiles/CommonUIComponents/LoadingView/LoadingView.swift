//
//  LoadingView.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import RxSwift

enum LoadingViewStyle {
    case full
    case fullWithClearBg
    case fullWithSmallWhiteBg
    case fullWithBgAndText(String)
    case dotsWith(count: Int)
}

class LoadingView: UIView {
    
    @IBOutlet weak var animatedDotsContainer: AnimatedDotsLoadingView!
    @IBOutlet weak var yCenterAligment: NSLayoutConstraint!
    @IBOutlet weak var operationDescription: UILabel!
    @IBOutlet weak var separatorView: UIView!

    private var style: LoadingViewStyle = .full
    private let disposeBag = DisposeBag()
    
    class func showInView(_ view: UIView?, style: LoadingViewStyle = .full) {
        guard let containerView = view else { return }
        if containerView.subviews.contains(where: { return $0 is LoadingView }) { return }
        if let customView = Bundle.main.loadNibNamed(LoadingView.identifier, owner: self, options: nil)?.first as? LoadingView {
            customView.translatesAutoresizingMaskIntoConstraints = false
            customView.setupWith(style: style)
            containerView.addSubview(customView)
            
            customView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            customView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            customView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            customView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animatedDotsContainer.alpha = 0
        
        Observable.zip(rx.didMoveToSuperview,
                       rx.layoutSubviews.take(1))
            .subscribe(onNext: { [weak self] _ in
                self?.animateAdding()
            })
            .disposed(by: disposeBag)
    }
    
    func setupWith(style: LoadingViewStyle) {
        self.style = style
        switch style {
        case .dotsWith(let dotsCount):
            animatedDotsContainer.dotsCount = dotsCount
            animatedDotsContainer.backgroundColor = .clear
        case .full, .fullWithClearBg:
            animatedDotsContainer.dotsCount = 7
            animatedDotsContainer.backgroundColor = .clear
        case .fullWithSmallWhiteBg:
            animatedDotsContainer.dotsCount = 7
            animatedDotsContainer.backgroundColor = .white
        case .fullWithBgAndText(let text):
            animatedDotsContainer.dotsCount = 7
            animatedDotsContainer.backgroundColor = .white
            operationDescription.isHidden = false
            operationDescription.text = text
            separatorView.isHidden = false
        }
    }
    
    class func hideLoaderFrom(_ view: UIView?, completion: (() -> ())? = nil) {
        guard let newView = view else { return }
        let loadingViews = newView.subviews.compactMap { $0 as? LoadingView }
        
        let group = DispatchGroup()

        guard !loadingViews.isEmpty else {
            completion?()
            return
        }
        
        for loadingView in loadingViews {
            group.enter()
            
            loadingView.close {
                group.leave()
            }
        }
        
        _ = group.notify(queue: DispatchQueue.main, execute: {
            completion?()
        })
    }
    
    func animateAdding() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: { [weak self] in
            self?.animatedDotsContainer?.alpha = 1
            switch self?.style ?? .full {
            case .full, .fullWithSmallWhiteBg, .fullWithBgAndText:
                if #available(iOS 13.0, *) {
                    self?.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.30)
                } else {
                    self?.backgroundColor = UIColor.white
                }
            case .dotsWith, .fullWithClearBg:
                self?.backgroundColor = UIColor.clear
            }
        }, completion: { [weak self] _ in
            switch self?.style ?? .full {
            case .fullWithSmallWhiteBg:
                self?.animatedDotsContainer.dropShadow(color: .darkGray,
                                                       opacity: 0.7,
                                                       radius: 3,
                                                       cornerRadius: self?.animatedDotsContainer.cornerRadius ?? 0)
            case .fullWithBgAndText:
                self?.animatedDotsContainer.dropShadow(color: .darkGray,
                                                       opacity: 0.7,
                                                       radius: 3,
                                                       cornerRadius: self?.animatedDotsContainer.cornerRadius ?? 0)
            default: return
            }
        })
    }
    
    fileprivate func close(completion: (() -> ())? = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: { [weak self] in
            self?.animatedDotsContainer?.alpha = 0
        }, completion: { [weak self] _ in
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.backgroundColor = UIColor.white
            }, completion: { [weak self] _ in
                self?.animatedDotsContainer?.stopAnimation()
                self?.animatedDotsContainer = nil
                self?.removeFromSuperview()
                completion?()
            })
        })
    }
}

class ImageLoadingView: Indicator {
    
    private let style: LoadingViewStyle
    private var container = UIView()
    
    init(frame: CGRect, style: LoadingViewStyle = .full) {
        self.style = style
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimatingView() {
        container.isHidden = false
        LoadingView.showInView(container, style: style)
    }
    
    func stopAnimatingView() {
        LoadingView.hideLoaderFrom(container)
        container.isHidden = true
    }
    
    var view: IndicatorView {
        return container
    }
    
    var centerOffset: CGPoint {
        return container.center
    }
}
