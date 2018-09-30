//
//  ResolvedInstances.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation

/// Class holding references to created instances to be shared. Instances created
/// for scope unique are not hold
final class ResolvedItems {
    
    /// Keeping a references to the resolved items
    var resolvedItems = [GraphDefinitionKey: Any]()
    
    /// Reference to item that can be resolved using property injection
    var resolvableItems = [HelixResolvable]()
    
    /// Boxed singletons using a reference type to be able to be shared
    var sharedSingletonsBoxed = Box<[GraphDefinitionKey: Any]>([:])
    
    /// Accessor for the boxed singletons
    var sharedSingletons: [GraphDefinitionKey: Any] {
        get {
            return sharedSingletonsBoxed.unboxed
        }
        set {
            sharedSingletonsBoxed.unboxed = newValue
        }
    }
    
    /// Non shared singletons
    var singletons = [GraphDefinitionKey: Any]()
    
    /// Boxed weak singletons using a reference type to be able to be shared
    var sharedWeakSingletonsBoxed = Box<[GraphDefinitionKey: Any]>([:])
    
    /// Accessor for the weak boxed singletons
    var sharedWeakSingletons: [GraphDefinitionKey: Any] {
        get {
            return sharedWeakSingletonsBoxed.unboxed
        }
        set {
            sharedWeakSingletonsBoxed.unboxed = newValue
        }
    }
    
    /// Non shared weak singletons
    var weakSingletons = [GraphDefinitionKey: Any]()
    
    // MARK: - Subscript
    
    subscript<T>(key key: GraphDefinitionKey, for scope: CreationScope, context: ResolvingContext) -> T? {
        get {
            let instance: Any?
            switch scope {
            case .lazySingleton, .singleton:
                instance = context.isCollaborating ? sharedSingletons[key] : singletons[key]
            case .weakSingleton:
                let singletons = context.isCollaborating ? sharedWeakSingletons : weakSingletons
                if let boxed = singletons[key] as? WeakBoxType {
                    instance = boxed.unboxed
                } else {
                    instance = singletons[key]
                }
            case .shared:
                instance = resolvedItems[key]
            case .unique:
                return nil
            }
            return instance.flatMap { $0 as? T }
        }
        set {
            switch scope {
            case .lazySingleton, .singleton:
                sharedSingletons[key] = newValue
                singletons[key] = newValue
            case .weakSingleton:
                sharedWeakSingletons[key] = newValue
                weakSingletons[key] = newValue
            case .shared:
                resolvedItems[key] = newValue
            case .unique:
                break
            }
        }
    }
}

extension ResolvedItems: CustomStringConvertible {
    
    var description: String {
        return "ResolvedItems - sharedSingletons: \(sharedSingletons.count) - singletong: \(singletons.count) - sharedWeakSingletons: \(sharedWeakSingletons.count) - weakSingletons: \(weakSingletons.count) - shared: \(resolvedItems.count)"
    }
}

extension ResolvedItems: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "ResolvedItems - sharedSingletons: \(sharedSingletons.count) - singletong: \(singletons.count) - sharedWeakSingletons: \(sharedWeakSingletons.count) - weakSingletons: \(weakSingletons.count) - shared: \(resolvedItems.count)"
    }
}
