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
        addInteractors(to: helix)
        addPresenters(to: helix)
        addViewControllers(to: helix)
//        do {
//            try helix.bootstrap()
//        } catch {
//            debugPrint(error)
//        }
        debugPrint(helix)
    }
    
    func addPresenters(to helix: Helix) {
        let service: APIServiceType = try! helix.resolve(APIServiceType.self) as! APIServiceType
        let interactor: LoginInteractorType = try! helix.resolve(LoginInteractorType.self, tag: "LoginInteractor") as! LoginInteractorType
        helix.register(.unique, type: LoginPresenterType.self, tag: "LoginPresenter") {
             try LoginPresenter(interactor: helix.resolve() as LoginInteractorType) as LoginPresenterType
//            return LoginPresenter(interactor: try helix.resolve()) as LoginPresenterType
        }
    }
    
    func addInteractors(to helix: Helix) {
//        helix.register(.unique, type: LoginInteractorType.self, tag: "LoginInteractor") { (apiService) -> LoginInteractorType in
//            LoginInteractor(apiServiceType: try helix.resolve()) as LoginInteractorType
//        }
        let interactorDef = helix.register(tag: "LoginInteractor") {
            try LoginInteractor(apiServiceType: helix.resolve() as APIServiceType) as LoginInteractorType
//            LoginInteractor(apiServiceType: try helix.resolve()) as LoginInteractorType
        }.solves(LoginInteractorType.self)
        debugPrint("## \(interactorDef)")
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

