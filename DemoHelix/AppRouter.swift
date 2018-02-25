//
//  AppRouter.swift
//  DemoHelix
//
//  Created by Alejandro Barros Cuetos on 25/02/2018.
//  Copyright © 2018 Filtercode Ltd. All rights reserved.
//

import UIKit

struct AppRouter {
    func start(with navController: UINavigationController) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        navController.viewControllers = [vc]
    }
}
