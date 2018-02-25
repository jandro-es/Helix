//
//  Optional+desc.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation

extension Optional {
    var desc: String {
        return self.map { "\($0)" } ?? "nil"
    }
}
