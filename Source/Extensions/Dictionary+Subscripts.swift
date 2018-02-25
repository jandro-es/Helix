//
//  Dictionary+Subscripts.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation

extension Dictionary {
    subscript(key: Key?) -> Value? {
        get {
            guard let key = key else { return nil }
            return self[key]
        }
        set {
            guard let key = key else { return }
            self[key] = newValue
        }
    }
}
