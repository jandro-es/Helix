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
    func pushHomeScreen(in navigationController: UINavigationController)
}

struct LoginPresenter: LoginPresenterType {
    
    let interactor: LoginInteractorType
    let router: LoginRouterType
    let homeRouter: HomeRouterType
    
    init(interactor: LoginInteractorType, router: LoginRouterType, homeRouter: HomeRouterType) {
        self.interactor = interactor
        self.router = router
        self.homeRouter = homeRouter
    }
    
    func login(with username: String, password: String, completionHandler: @escaping (Bool) -> Void) {
        interactor.login(with: username, password: password) { (succeed) in
            completionHandler(succeed)
        }
    }
    
    func pushHomeScreen(in navigationController: UINavigationController) {
        homeRouter.start(in: navigationController)
    }
}
