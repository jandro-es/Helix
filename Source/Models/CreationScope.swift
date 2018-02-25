//
//  ComponentScope.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation

/// Enumeration defining the possible creation scopes
///
/// - unique: New instance every time is resolved
/// - shared: Different objects in the graph share the same instance
/// - lazySingleton: Is created when first needed and is retained and reused everytime
/// - singleton: Same as singleton but the instance is created when the Helix is started
/// - weakSingleton: Same as lazySingleton but Helix retains a weak reference
public enum CreationScope {

    case unique, shared, lazySingleton, singleton, weakSingleton
}
