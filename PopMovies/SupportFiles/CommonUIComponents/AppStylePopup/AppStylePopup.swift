//
//  AppStylePopup.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum PopupDirection {
    case vertical, horizontal
}

class AppStylePopup: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitlesStackView: UIStackView!
    @IBOutlet weak var verticalButtonsStackView: UIStackView!
    @IBOutlet weak var horizontalButtonsStackView: UIStackView!
    @IBOutlet weak var buttonsBottomOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsContainerLeadingConstraint: NSLayoutConstraint!
        
    static var lastPopup: AppStylePopup?
    
    static func show(viewData: InformalViewData) {
        guard let popupViewController = AppStylePopup.initFromStoryboard() else {
            fatalError("Could not init AppStylePopup from storyboard")
        }
        
        popupViewController.viewData = viewData
        
        guard let target = DIManager.shared.resolve(UINavigationController.self) else { return }

        (target.presentedViewController == nil ? target : target.presentedViewController)?.present(popupViewController, animated: true, completion: nil)
    }
    
    private let disposeBag = DisposeBag()
    
    var viewData: InformalViewData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        popupView.dropShadow(color: .black, opacity: 0.6, radius: 6, cornerRadius: 4)
    }
    
    func setup() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
         } else {
            view.backgroundColor = UIColor.white
         }
        
        titleLabel.text = viewData.title
        
        imageContainerView.isHidden = viewData.describingIcon == nil
        imageView.image = viewData.describingIcon
        
        [subtitlesStackView, verticalButtonsStackView, horizontalButtonsStackView]
            .forEach {
                $0.arrangedSubviews.forEach { [weak self] view in
                    self?.subtitlesStackView.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
            }
        
        switch self.viewData.popupDirection {
        case .horizontal:
            subtitlesStackView.alignment = .leading
            buttonsContainerLeadingConstraint.isActive = false
            buttonsBottomOffsetConstraint.constant = 0
        case .vertical:
            subtitlesStackView.alignment = .center
            buttonsContainerLeadingConstraint.isActive = true
            buttonsBottomOffsetConstraint.constant = 25
        }
        
        viewData.messages.forEach { message in
            guard !message.isTitle else { return }
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 18)
            label.numberOfLines = 0
                        
            switch viewData.popupDirection {
            case .horizontal:
                label.textAlignment = .natural
            case .vertical:
                label.textAlignment = .center
            }
            
            label.textColor = UIColor(named: "AppStylePopupSubtitle")
            
            switch message {
            case .title(let text):
                label.text = text
            case .description(let text):
                label.text = text
            case .subdescription(let text):
                label.text = text
            }
            
            subtitlesStackView.addArrangedSubview(label)
        }
        
        if viewData.actions.isEmpty {
            viewData.actions.append(.mainAction("Ok", nil))
        }
        
        horizontalButtonsStackView.isHidden = self.viewData.popupDirection == .vertical
        verticalButtonsStackView.isHidden = self.viewData.popupDirection == .horizontal
        
        viewData.actions
            .sorted(by: { val1, val2 in
                switch (val1, val2) {
                case (.defaultAction, .mainAction):
                    return true
                case (.mainAction, .defaultAction):
                    return false
                default:
                    return false
                }
            })
            .forEach { [weak self] action in
                let button = UIButton()

                switch action {
                case .defaultAction:
                    button.backgroundColor = .clear
                    button.setTitleColor(UIColor(named: "profileField"), for: .normal)
                case .mainAction:
                    button.backgroundColor = #colorLiteral(red: 0.1882352941, green: 0.3098039216, blue: 0.9960784314, alpha: 1)
                    button.setTitleColor(.white, for: .normal)
                }
                
                button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                button.layer.cornerRadius = 2
                
                switch action {
                case .defaultAction(let title, let action):
                    button.setTitle(title, for: .normal)

                    button.rx.tap
                        .subscribe(onNext: { _ in
                            self?.dismiss(animated: true, completion: nil)
                            action?()
                        })
                        .disposed(by: disposeBag)
                case .mainAction(let title, let action):
                    button.setTitle(title, for: .normal)

                    button.rx.tap
                        .subscribe(onNext: { _ in
                            self?.dismiss(animated: true, completion: nil)
                            action?()
                        })
                        .disposed(by: disposeBag)
                }
                
                if self?.viewData.popupDirection == .horizontal {
                    horizontalButtonsStackView.addArrangedSubview(button)
                } else {
                    verticalButtonsStackView.addArrangedSubview(button)
                }
                
                let horizontalOffset = 24 * UIScreen.ratio
                let verticalOffset = 10 * UIScreen.ratio
                button.contentEdgeInsets = UIEdgeInsets(top: verticalOffset, left: horizontalOffset,
                                                        bottom: verticalOffset, right: horizontalOffset)
                
                button.translatesAutoresizingMaskIntoConstraints = false
                button.heightAnchor.constraint(equalToConstant: 55 * UIScreen.ratio).isActive = true
            }
    }
}
