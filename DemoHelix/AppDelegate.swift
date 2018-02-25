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
    private var baseNavigationController: UINavigationController!
    private let appRouter = AppRouter()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        setupDependencyInjection()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        baseNavigationController = UINavigationController()
        appRouter.start(with: baseNavigationController)
        window?.rootViewController = baseNavigationController
        window?.makeKeyAndVisible()
        return true
    }
    
    func setupDependencyInjection() {
        helix = Helix(parent: nil, configLambda: nil)
        addServices(to: helix)
        addPresenters(to: helix)
        addInteractors(to: helix)
        addViewControllers(to: helix)
        do {
            try helix.bootstrap()
        } catch {
            debugPrint(error)
        }
        debugPrint(helix)
    }
    
    func addPresenters(to helix: Helix) {
        helix.register(tag: "LoginPresenter") {
            LoginPresenter(interactor: try helix.resolve()) as LoginPresenterType
        }
    }
    
    func addInteractors(to helix: Helix) {
        helix.register() {
            LoginInteractor(apiServiceType: try helix.resolve()) as LoginInteractorType
        }
    }
    
    func addServices(to helix: Helix) {
        helix.register(.lazySingleton) {
            APIService(baseURL: URL(string: "https://test.co.uk")!, cacheTTL: 200, endpoints: ["/login"]) as APIServiceType
        }
    }
    
    func addViewControllers(to helix: Helix) {
        helix.register(storyboardType: LoginViewController.self, tag: "LoginViewController")
            .resolvingProperties { (helix, vc) in
                vc.presenter = try helix.resolve(tag: "LoginPresenter") as LoginPresenterType
        }
        Helix.ibHelixes = [helix]
    }
}

