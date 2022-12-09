//
//  ErrorViewMessaage.swift
//  PopMovies
//
//  Created by ecovali on 3/5/20.
//  Copyright © 2020 ecovali. All rights reserved.
//
import Foundation
import UIKit
import RxSwift

enum ErrorViewMessaage: Equatable {
    case title(String)
    case description(String)
    case subdescription(String)
    
    var isTitle: Bool {
        switch self {
        case .title:
            return true
        default:
            return false
        }
    }
    
    static func == (lhs: ErrorViewMessaage, rhs: ErrorViewMessaage) -> Bool {
        switch (lhs, rhs) {
        case (.title(let lTitle), .title(let rTitle)):
            return lTitle == rTitle
        case (.description(let lDescription), .description(let rDescription)):
            return lDescription == rDescription
        case (.subdescription(let lSubdescription), .subdescription(let rSubdescription)):
            return lSubdescription == rSubdescription
        default: return false
        }
    }
}

enum ErrorViewAction: Equatable {
    case defaultAction(String, (() -> ())?)
    case mainAction(String, (() -> ())?)
    
    static func == (lhs: ErrorViewAction, rhs: ErrorViewAction) -> Bool {
        switch (lhs, rhs) {
        case (.defaultAction(let lTitle, _), .defaultAction(let rTitle, _)):
            return lTitle == rTitle
        case (.mainAction(let nameL, _), .mainAction(let nameR, _)):
            return nameL == nameR
        default: return false
        }
    }
}

struct InformalViewAction {
    
    let title: String
    let action: (() -> ())?
    
    init(title: String, action: (() -> ())? = nil) {
        self.title = title
        self.action = action
    }
}

struct InformalViewData: Equatable {
    
    var messages: [ErrorViewMessaage]
    var actions: [ErrorViewAction]
    var describingIcon: UIImage?
    var popupDirection: PopupDirection = .horizontal
    
    var title: String {
        for message in messages {
            if case .title(let title) = message {
                return title
            }
        }
        return ""
    }
    
    var message: String {
        for message in messages {
            if case .description(let title) = message {
                return title
            }
        }
        return ""
    }
    
    var action: (() -> ())? {
        if case .mainAction(_, let action)? = actions.first {
            return action
        }
        return nil
    }
    
    var actionTitle: String? {
        if case .mainAction(let title, _)? = actions.first {
            return title
        }
        return nil
    }
    
    init(title: String? = nil, message: String, buttonTitle: String? = nil, describingIcon: UIImage? = nil, handler: (() -> ())? = nil) {
        self.messages = []
        if let newTitle = title {
            self.messages.append(.title(newTitle))
        }
        messages.append(.description(message))
        self.actions = []
        if let title = buttonTitle, let newHandler = handler {
            self.actions = [.mainAction(title, newHandler)]
        }
        self.describingIcon = describingIcon
    }
    
    init(_ title: String? = nil, message: String,
         mainAction: InformalViewAction? = nil,
         dissmisAction: InformalViewAction? = nil,
         describingIcon: UIImage? = nil,
         popupDirection: PopupDirection = .horizontal) {
        
        self.popupDirection = popupDirection
        self.messages = []
        
        if let newTitle = title {
            self.messages.append(.title(newTitle))
        }
        
        messages.append(.description(message))
        
        self.actions = []
        
        if let action = mainAction {
            self.actions.append(.mainAction(action.title, action.action))
        }
        
        if let action = dissmisAction {
            self.actions.append(.defaultAction(action.title, action.action))
        }
        
        self.describingIcon = describingIcon
    }
    
    init(messages: [ErrorViewMessaage], actions: [ErrorViewAction] = [], icon: UIImage? = nil) {
        self.messages = messages
        self.actions = actions
        self.describingIcon = icon
    }
    
    static func == (lhs: InformalViewData, rhs: InformalViewData) -> Bool {
        let sameIcon = (lhs.describingIcon ?? UIImage()).pngData() == (rhs.describingIcon ?? UIImage()).pngData()
        return lhs.title == rhs.title &&
               lhs.message == lhs.message &&
               sameIcon
    }
}
