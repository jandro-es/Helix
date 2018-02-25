//
//  APIService.swift
//  DemoHelix
//
//  Created by Alejandro Barros Cuetos on 24/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation
import Helix

protocol APIServiceType {
    func loginRequest(for username: String, password: String, completionHandler: @escaping (Bool) -> Void)
}

struct APIService: APIServiceType {
    
    let baseURL: URL
    let cacheTTL: Int
    let endpoints: [String]
    
    func loginRequest(for username: String, password: String, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
}
