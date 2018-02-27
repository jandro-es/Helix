//
//  HomePresenter.swift
//  DemoHelix
//
//  Created by Alejandro Barros on 27/02/2018.
//  Copyright © 2018 Filtercode Ltd. All rights reserved.
//

import UIKit

protocol HomePresenterType {
    
}

struct HomePresenter: HomePresenterType {
    
    let interactor: HomeInteractorType
    let router: HomeRouterType
    
    init(interactor: HomeInteractorType, router: HomeRouterType) {
        self.interactor = interactor
        self.router = router
    }
}
