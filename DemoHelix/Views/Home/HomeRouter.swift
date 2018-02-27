//
//  HomeRouter.swift
//  DemoHelix
//
//  Created by Alejandro Barros on 27/02/2018.
//  Copyright © 2018 Filtercode Ltd. All rights reserved.
//

import UIKit

protocol HomeRouterType {
    func start(in navigationController: UINavigationController)
}

struct HomeRouter: HomeRouterType {
    
    func start(in navigationController: UINavigationController) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        navigationController.pushViewController(vc, animated: true)
    }
}
