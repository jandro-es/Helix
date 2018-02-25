//
//  LoginInteractor.swift
//  DemoHelix
//
//  Created by Alejandro Barros Cuetos on 25/02/2018.
//  Copyright © 2018 Filtercode Ltd. All rights reserved.
//

import Foundation

protocol LoginInteractorType {
    func login(with username: String, password: String, completionHandler: @escaping (Bool) -> Void)
}

struct LoginInteractor: LoginInteractorType {
    
    let apiService: APIServiceType
    
    init(apiServiceType: APIServiceType) {
        self.apiService = apiServiceType
    }
    
    func login(with username: String, password: String, completionHandler: @escaping (Bool) -> Void) {
        apiService.loginRequest(for: username, password: password) { (succeed) in
            completionHandler(succeed)
        }
    }
}
