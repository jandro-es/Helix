// The MIT License
//
// Copyright (c) 2018-2019 Alejandro Barros Cuetos. jandro@filtercode.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
