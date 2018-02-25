//
//  LoginPresenter.swift
//  DemoHelix
//
//  Created by Alejandro Barros Cuetos on 25/02/2018.
//  Copyright © 2018 Filtercode Ltd. All rights reserved.
//

import UIKit

protocol LoginPresenterType {
    func login(with username: String, password: String, completionHandler: @escaping (Bool) -> Void)
}

struct LoginPresenter: LoginPresenterType {
    
    let interactor: LoginInteractorType
    
    init(interactor: LoginInteractorType) {
        self.interactor = interactor
    }
    
    func login(with username: String, password: String, completionHandler: @escaping (Bool) -> Void) {
        interactor.login(with: username, password: password) { (succeed) in
            completionHandler(succeed)
        }
    }
}
