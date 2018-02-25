//
//  Box.swift
//  Helix
//
//  Created by Alejandro Barros Cuetos on 31/12/2017.
//  Copyright © 2017 Filtercode Ltd. All rights reserved.
//

import Foundation

protocol BoxType {
    var unboxed: Any? { get }
}

protocol WeakBoxType {
    var unboxed: AnyObject? { get }
}

// Box Pattern to store value and reference types
// If used with reference objects, keep in mind that it will keep
// a strong reference to it.
final class Box<T> {
    
    /// The unboxed object of type T
    var unboxed: T
    
    /// Initializes a Box with the given value
    ///
    /// - Parameter value: The value of type T to store
    init(_ value: T) {
        self.unboxed = value
    }
}

// MARK: - Optional + BoxType

extension Optional: BoxType {
    var unboxed: Any? {
        return self ?? nil
    }
}

// MARK: - ImplicitlyUnwrappedOptional + BoxType

extension ImplicitlyUnwrappedOptional: BoxType {
    var unboxed: Any? {
        return self ?? nil
    }
}

/// Box pattern for storing weak references
/// We can only store `Reference Types`
final class WeakBox<T>: WeakBoxType {
    
    // MARK: - Internal properties
    
    /// The unboxed object
    weak var unboxed: AnyObject?
    
    /// The unboxed object cast to the optional generic type
    var value: T? {
        return unboxed as? T
    }
    
    // MARK: - Initializers
    
    /// Initializes a WeakBox of the specified generic type
    /// it will stop execution if we try to store a non reference type
    ///
    /// - Parameter object: The object to store of type T
    init(_ object: T) {
        // We transform the generic into a weak reference to AnyObject
        weak var weakValue: AnyObject? = object as AnyObject
        guard weakValue != nil else {
            fatalError("We can only store weak references for reference types")
        }
        self.unboxed = weakValue
    }
}

// MARK: - CustomDebugStringConvertible

extension WeakBox: CustomDebugStringConvertible {
    var debugDescription: String {
        return "WeakBox of type: \(T.self)"
    }
}

extension Box: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Box of type: \(T.self)"
    }
}

// MARK: - CustomStringConvertible

extension WeakBox: CustomStringConvertible {
    var description: String {
        return "WeakBox of type: \(T.self)"
    }
}

extension Box: CustomStringConvertible {
    var description: String {
        return "WeakBox of type: \(T.self)"
    }
}
