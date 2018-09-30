//
//  AppDelegate.swift
//  DemoHelix
//
//  Created by Alejandro Barros Cuetos on 24/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import UIKit
import Helix

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var helix: Helix!
    private var servicesHelix: Helix!
    private var baseNavigationController: UINavigationController!
    private let appRouter = AppRouter()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        setupDependencyInjection()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        baseNavigationController = UINavigationController()
        appRouter.start(with: baseNavigationController)
        window?.rootViewController = baseNavigationController
        window?.makeKeyAndVisible()
        return true
    }
    
    func setupDependencyInjection() {
        servicesHelix = Helix(parent: nil, configLambda: nil)
        helix = Helix(parent: servicesHelix, configLambda: nil)
        addServices(to: servicesHelix)
        addInteractors(to: helix)
        addRouters(to: helix)
        addPresenters(to: helix)
        addViewControllers(to: helix)
    }
    
    func addPresenters(to helix: Helix) {
        helix.register(.unique) {
            LoginPresenter(interactor: try helix.resolve(), router: try helix.resolve(), homeRouter: try helix.resolve()) as LoginPresenterType
        }
        helix.register(.unique) {
            HomePresenter(interactor: try helix.resolve(), router: try helix.resolve()) as HomePresenterType
        }
    }
    
    func addInteractors(to helix: Helix) {
        helix.register(.unique) {
            LoginInteractor(apiService: try helix.resolve()) as LoginInteractorType
        }
        helix.register(.unique) {
            HomeInteractor(apiService: try helix.resolve()) as HomeInteractorType
        }
    }
    
    func addServices(to helix: Helix) {
        helix.register(.lazySingleton) {
            APIService(baseURL: URL(string: "https://test.co.uk")!, cacheTTL: 200, endpoints: ["/login"]) as APIServiceType
        }
    }
    
    func addRouters(to helix: Helix) {
        helix.register(.unique) {
            LoginRouter() as LoginRouterType
        }
        helix.register(.unique) {
            HomeRouter() as HomeRouterType
        }
    }
    
    func addViewControllers(to helix: Helix) {
        helix.register(storyboardType: LoginViewController.self, tag: "LoginViewController")
            .resolvingProperties { (helix, vc) in
                vc.presenter = try helix.resolve(tag: "LoginPresenter") as LoginPresenterType
        }
        
        helix.register(storyboardType: HomeViewController.self, tag: "HomeViewController")
            .resolvingProperties { (helix, vc) in
                vc.presenter = try helix.resolve(tag: "HomePresenter") as HomePresenterType
        }
        Helix.ibHelixes = [helix]
    }
}

