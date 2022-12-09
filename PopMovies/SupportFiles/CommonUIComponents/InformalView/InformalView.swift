//
//  InformalView.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class InformalView: UIView {
    
    @IBOutlet weak var errorIcon: UIImageView!
    @IBOutlet weak var labelsStackView: UIStackView!
    @IBOutlet weak var buttonsView: UIStackView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    private var addAnimated: Bool = true
    private let disposeBag = DisposeBag()
    
    static func showInView(_ view: UIView?, with viewData: InformalViewData, addAnimated: Bool = true, fill: Bool = true) {
        guard let containerView = view else { return }
        
        if let currentView = containerView.subviews.first(where: { return $0 is InformalView }) {
            currentView.removeFromSuperview()
        }
        
        guard let customView = Bundle.main.loadNibNamed(InformalView.identifier, owner: self, options: nil)?.first as? InformalView else {
            return
        }
        
        customView.addAnimated = addAnimated
        
        if addAnimated {
            customView.layer.opacity = 0
        }
        
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.setupWith(viewData: viewData)
        view?.addSubview(customView)
        
        let isInList = view is UITableView || !fill
        
        if !isInList {
            customView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        } else {
            customView.topAnchor.constraint(equalTo: containerView.topAnchor,
                                            constant: (containerView as? UITableView)?.tableHeaderView?.height ?? 0).isActive = true
        }
        
        if !isInList {
            customView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            customView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        }
        
        customView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        
        if isInList {
            let height = (view?.height ?? 1) - ((containerView as? UITableView)?.tableHeaderView?.height ?? 0)
            customView.heightAnchor.constraint(equalToConstant: height).isActive = true
            customView.widthAnchor.constraint(equalToConstant: view?.width ?? 1).isActive = true
         }
    }
    
    var requiredHeight: CGFloat {
        let verticalMinimalOffset: CGFloat = 50
        return mainStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + verticalMinimalOffset
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
            backgroundColor = UIColor.systemBackground
        } else {
//            AppThemeManager.shared.currentTheme
//                .subscribe(onNext: { [weak self] theme in
//                    self?.backgroundColor = theme == .dark ? UIColor.black : UIColor.white
//                    self?.labelsStackView.arrangedSubviews
//                        .compactMap { $0 as? UILabel }
//                        .forEach { label in
//                            label.textColor = AppThemes.labelColor
//                        }
//                })
//                .disposed(by: disposeBag)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if addAnimated {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.layer.opacity = 1
            }
        }
    }
    
    static func hideFromView(_ view: UIView?) {
        for subView in view?.subviews ?? [] {
            if let informalView = subView as? InformalView {
                informalView.removeFromSuperview()
            }
        }
    }
    
    fileprivate func setupWith(viewData: InformalViewData) {
        errorIcon.image = viewData.describingIcon
        errorIcon.superview?.isHidden = viewData.describingIcon == nil
        labelsStackView.arrangedSubviews.forEach { view in
            labelsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        buttonsView.arrangedSubviews.forEach { view in
            buttonsView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        viewData.messages.forEach { message in
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 16)
            label.numberOfLines = 0
            label.textColor = UIColor.hexStringToUIColor("#808080")
                        
            switch message {
            case .title(let text):
                label.text = text
                label.font = UIFont.systemFont(ofSize: 18)
                
                if #available(iOS 13.0, *) {
                    label.textColor = UIColor.label
                } else {
                    label.textColor = UIColor.white
                }
            case .description(let text):
                label.text = text
            case .subdescription(let text):
                label.text = text
            }
            labelsStackView.addArrangedSubview(label)
        }
        
        buttonsView.isHidden = viewData.actions.isEmpty
        
        guard !viewData.actions.isEmpty else { return }
        
        viewData.actions.forEach { action in
            let button = UIButton()
            button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
            button.backgroundColor = #colorLiteral(red: 0.1882352941, green: 0.3098039216, blue: 0.9960784314, alpha: 1)
            button.layer.cornerRadius = 4
            switch action {
            case .defaultAction(let title, let action):
                button.setTitle(title, for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.rx.tap
                    .subscribe(onNext: { _ in
                        action?()
                    })
                    .disposed(by: disposeBag)
            case .mainAction(let title, let action):
                button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                button.setTitle(title, for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.rx.tap
                    .subscribe(onNext: { _ in
                        action?()
                    })
                    .disposed(by: disposeBag)
            }
            buttonsView.addArrangedSubview(button)
            
            let horizontalOffset = 32 * UIScreen.ratio
            let verticalOffset = 16 * UIScreen.ratio
            button.contentEdgeInsets = UIEdgeInsets(top: verticalOffset, left: horizontalOffset,
                                                    bottom: verticalOffset, right: horizontalOffset)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 55 * UIScreen.ratio).isActive = true
        }
    }
}
