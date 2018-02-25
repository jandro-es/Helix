//
//  Resolvable.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation

/// Resolvable protocol provides some extension points for resolving dependencies with property injection.

/// Protocol to implement to solve DI using property injection
public protocol HelixResolvable {
    /// This method will be called right after instance is created by the container.
    
    /// This method will be called just after the instance is created by the Helix
    ///
    /// - Parameter container: The Helix instance that called it
    func resolveDependencies(with helix: Helix)

    /// This method will be called when all the dependencies are resolved
    func didResolveDependencies()
}

extension HelixResolvable {
    func resolveDependencies(with helix: Helix) {}
    func didResolveDependencies() {}
}
