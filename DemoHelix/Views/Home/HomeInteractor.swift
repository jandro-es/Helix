//
//  HomeInteractor.swift
//  DemoHelix
//
//  Created by Alejandro Barros on 27/02/2018.
//  Copyright © 2018 Filtercode Ltd. All rights reserved.
//

import Foundation

protocol HomeInteractorType {
    
}

struct HomeInteractor: HomeInteractorType {
    
    let apiService: APIServiceType
    
    init(apiService: APIServiceType) {
        self.apiService = apiService
    }
}
